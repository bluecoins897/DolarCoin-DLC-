// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//***Contract for Binance Smart Chain(BSC)***//

contract DolarCoin is ReentrancyGuard {
    // Constantes y variables inmutables
    string public constant name = "DolarCoin";
    string public constant symbol = "DLC";
    uint8 public constant decimals = 18;
    uint256 public constant maxSupply = 21_000_000 * (10 ** decimals); // Suministro total y fijo de 21 millones, los usuarios son los encargados de realizar la creación de los tokens, para poder comprar los tokens tiene que haber mineria previa.
    
    // Variables de estado
    address public creatorAddress;
    uint256 public creatorShare; // 2% del suministro para el creador para futuros proyectos.
    uint256 public totalMined; // Cantidad de tokens minados por los usuarios o mineros.
    uint256 public totalMiners; // Total de mineros
    uint256 public rewardHalvingInterval = 5_000; // Intervalo de halving cada 5000 bloques.
    uint256 public miningRewardRate = 2000 * (10 ** decimals); // Recompensa inicial 2000 DLC, 50% a los usuarios (mineros) y 50% restante al contrato para proveer liquidez.
    uint256 public difficulty = 2**240; // Dificultad inicial de minería.
    uint256 private feeBalance; // Balance de comisiones para liquidez si falta BNB en el contrato. 
    uint256 public basePriceDLC = 100_000; // Precio sugerido base de DLC, se establece el precio con la primera compra.
    uint256 public transactionFee = 0.001 ether;// Comisión por compra/venta que se usa para cubrir si falta BNB en el contrato.
    
    bool public maxSupplyReached = false; // Indica si se alcanzó el suministro máximo fijo de tokens.
    bool internal priceInitialized = false; // Indica si el precio ha sido inicializado solo en la primera compra.
    
    bytes32 public lastHash; // Hash de la última minería.
    uint256 public lastHashBlockNumber; // Número del bloque de la última minería.
    uint256 public lastBlockTime; // Tiempo del último bloque minado.
    
    address[] public minerAddresses; // Dirección de los mineros.
    mapping(address => uint256) private balances; // Balances de los usuarios.
    mapping(address => bool) public miners; // Mineros verificados.
    mapping(address => bytes32) public commitHashes; // Hashes de los commits de transacción.
    mapping(address => uint256) public commitTimestamp; // Tiempos de los commits de transacción.
    mapping(address => mapping(address => uint256)) public allowance; // Permisos de transferencia usados por los exchange.

    // Eventos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokenPurchased(address indexed buyer, uint256 bnbAmount, uint256 tokenAmount);
    event TokenSold(address indexed seller, uint256 bnbAmount, uint256 tokenAmount);
    event BlockMined(address indexed miner, uint256 reward);
    event FeeCollected(address indexed from, uint256 amount);
    event MinerRewardDistributed(address indexed miner, uint256 reward);
    event DifficultyAdjusted(uint256 newDifficulty);
    event PriceUpdated(uint256 newPrice);
    event CommitMade(address indexed user, bytes32 commitHash, uint256 timestamp);
    event CommitRevealed(address indexed user, uint256 value, uint256 timestamp);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor
    constructor(address creator) {
        require(creator != address(0), "Creator address cannot be zero");
        creatorShare = (maxSupply * 2) / 100;  // Asignación 2% para el creador para futuros proyectos.
        balances[creator] = creatorShare;
        emit Transfer(address(0), creator, creatorShare);
        creatorAddress = address(0); // Se renuncia al derecho del contrato, esto garantiza que sea autónomo.
    }

    // Modificadores
    modifier onlyPositive(uint256 amount) {
        require(amount > 0 && amount <= maxSupply, "Amount must be positive and within range");
        _;
    }

    modifier whenSupplyNotReached() {
        require(!maxSupplyReached, "Max supply has been reached");
        _;
    }

    modifier whenPriceInitialized() {
        require(priceInitialized, "Price not initialized");
        _;
    }

    modifier noFrontRunning() {
        uint256 currentBlockNumber = block.number;
        uint256 currentTimestamp = block.timestamp;
        require(lastHashBlockNumber != currentBlockNumber || lastHash != keccak256(abi.encodePacked(currentTimestamp, msg.sender)), "Potential front-running detected");
        _;
    }

    modifier commitValid() {
        require(block.timestamp > commitTimestamp[msg.sender] + 1, "Commit period is too soon");
        _;
    }

    modifier commitRevealed() {
        require(commitHashes[msg.sender] != bytes32(0), "Commit reveal not found");
        _;
    }

    

    // Función para ver el balance de un usuario.
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Función para ajustar el precio de DLC basado en la oferta y demanda.
    function adjustPrice() private nonReentrant noFrontRunning {
        uint256 bnbBalance = address(this).balance;
        uint256 tokenBalance = balances[address(this)];
        
        if (tokenBalance > 0) {
            basePriceDLC = (bnbBalance * 1 ether) / tokenBalance;
            emit PriceUpdated(basePriceDLC);
        }
    }

    // Función para comprar tokens.
    function buyTokens() external payable onlyPositive(msg.value) nonReentrant whenSupplyNotReached noFrontRunning {
        require(totalMined > 0, "Mining must occur before tokens can be bought");
        uint256 availableForPurchase = totalMined;
        require(availableForPurchase > 0, "No tokens available for purchase");
        
        // Inicializar el precio la primera vez que se compra.
        if (!priceInitialized) {
            priceInitialized = true;
            emit PriceUpdated(basePriceDLC);
        }

        uint256 tokensToBuy = getTokensForBNB(msg.value - transactionFee);
        require(tokensToBuy > 0, "Cannot purchase zero tokens");
        require(availableForPurchase >= tokensToBuy, "Not enough tokens available");
        balances[address(this)] -= tokensToBuy;
        balances[msg.sender] += tokensToBuy;
        feeBalance += transactionFee;
        emit FeeCollected(msg.sender, transactionFee);
        emit TokenPurchased(msg.sender, msg.value, tokensToBuy);
        adjustPrice();
    }

    // Función para vender tokens.
    function sellTokens(uint256 tokenAmount) external nonReentrant noFrontRunning {
        require(balances[msg.sender] >= tokenAmount, "Insufficient tokens");
        uint256 bnbAmount = getBNBForTokens(tokenAmount);
        if (address(this).balance < bnbAmount) {
            require(feeBalance >= (bnbAmount - address(this).balance), "Insufficient contract BNB and fee balance");
            feeBalance -= (bnbAmount - address(this).balance);
        }
        balances[msg.sender] -= tokenAmount;
        balances[address(this)] += tokenAmount; 
        adjustPrice();
        payable(msg.sender).transfer(bnbAmount);
        emit TokenSold(msg.sender, bnbAmount, tokenAmount);
    }

    // Función para calcular la cantidad de tokens por BNB.
    function getTokensForBNB(uint256 bnbAmount) public view returns (uint256) {
        uint256 tokenBalance = balances[address(this)];
        require(tokenBalance > 0, "No tokens available in the contract");
        return (bnbAmount * tokenBalance) / address(this).balance;
    }

    // Función para calcular la cantidad de BNB por tokens.
    function getBNBForTokens(uint256 tokenAmount) public view returns (uint256) {
        uint256 tokenBalance = balances[address(this)];
        require(tokenBalance > 0, "No tokens available in the contract");
        return (tokenAmount * address(this).balance) / tokenBalance;
    }

    // Función para obtener el precio base de DLC.
    function getPrice() public view returns (uint256) {
        return basePriceDLC;
    }

    // Función para aprobar a un tercero para gastar tokens en nombre de un usuario.
    function approve(address spender, uint256 amount) public nonReentrant noFrontRunning whenSupplyNotReached {
        require(spender != address(0), "Spender address cannot be zero");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    // Función para transferir tokens desde un usuario aprobado.
    function transferFrom(address sender, address recipient, uint256 amount) public nonReentrant noFrontRunning whenSupplyNotReached {
        require(sender != address(0), "Sender address cannot be zero");
        require(recipient != address(0), "Recipient address cannot be zero");
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
    }

    // Función para transferir tokens.
    function transfer(address recipient, uint256 amount) public nonReentrant noFrontRunning {
        require(recipient != address(0), "Recipient address cannot be zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }

    // Función para obtener la recompensa de minería inicial de 1000 DLC.
    function getMiningReward() public view returns (uint256) {
        uint256 halvingPeriodsPassed = totalMiners / rewardHalvingInterval;
        uint256 reward = miningRewardRate;
        for (uint256 i = 0; i < halvingPeriodsPassed; i++) {
            reward = reward / 2;
        }
        if (totalMined + reward > maxSupply) {
            reward = maxSupply - totalMined;
        }
        return reward;
    }

    // Función para realizar la minería simulada, los usuarios son los encargados del futuro de DolarCoin(DLC) generando los tokens para que otros usuarios puedan comprar, de esta forma no hay ninguna centralización para que sea inclusivo y todos puedan participar creando una moneda deflacionaria y como resguardo de valor a largo plazo.
    function mineBlock(uint256 nonce) external nonReentrant whenSupplyNotReached noFrontRunning {
        require(totalMined < maxSupply, "Max supply reached, cannot mine more blocks"); // Verifica que no exceda el suministro máximo de 21 millones documentado claramente.
        uint256 currentTime = block.timestamp;
        if (lastBlockTime != 0) {
            uint256 timeElapsed = currentTime - lastBlockTime;
            if (timeElapsed < 600) {
                difficulty += 2;
            } else if (timeElapsed > 600) {
                difficulty -= 2;
            }
        }
        bytes32 hash = keccak256(abi.encodePacked(lastHash, nonce, msg.sender, currentTime));
        require(uint256(hash) < difficulty, "Hash does not meet difficulty requirements");
        uint256 reward = getMiningReward();
        require(reward > 0, "Mining reward is zero");
        uint256 minerReward = reward / 2;
        uint256 contractReward = reward - minerReward;
        balances[msg.sender] += minerReward;
        balances[address(this)] += contractReward;
        totalMined += reward;
        totalMiners += 1;
        lastHash = hash;
        lastHashBlockNumber = block.number;
        lastBlockTime = currentTime;
        if (totalMined >= maxSupply) {
            maxSupplyReached = true;
        }
        miners[msg.sender] = true;
        minerAddresses.push(msg.sender);
        emit BlockMined(msg.sender, minerReward);
        emit BlockMined(address(this), contractReward);
        emit DifficultyAdjusted(difficulty);
    }
}
