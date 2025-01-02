
### **README en español**

```markdown
# DolarCoin (DLC) - Token de Binance Smart Chain

**DolarCoin (DLC)** es un token descentralizado desplegado en Binance Smart Chain (BSC). Este token opera con un suministro total fijo de 21 millones de tokens y cuenta con un mecanismo de minería en el que los usuarios son recompensados con tokens por minar. También incluye un sistema de comisiones por transacción que se utiliza para proporcionar liquidez para futuras compras.

## Características

- **Suministro total**: 21,000,000 DLC (suministro fijo).
- **Minería**: Los usuarios minan tokens DLC resolviendo un rompecabezas criptográfico y son recompensados con tokens DLC.
- **Mecanismo de Halving**: Las recompensas de minería se reducen a la mitad cada 5,000 bloques.
- **Deflacionario**: Un porcentaje de los tokens minados se bloquean en el contrato para proporcionar liquidez.
- **Comisiones por transacción**: Cada transacción tiene una pequeña comisión en BNB que se utiliza para asegurar que el contrato tenga suficiente liquidez.

## Cómo Funciona

### Minería
DolarCoin utiliza un mecanismo de minería donde los usuarios pueden resolver un rompecabezas criptográfico para minar nuevos bloques y ganar recompensas. La dificultad se ajusta en función del tiempo transcurrido entre bloques, creando un modelo deflacionario.

- **Sistema de Recompensas**: La recompensa de minería comienza en 2000 DLC y se reduce a la mitad cada 5,000 bloques.
- **Suministro Máximo**: El suministro total de DLC está limitado a 21 millones de tokens. Una vez alcanzado este límite, no se podrán minar más tokens.

### Compra y Venta de Tokens
Los tokens DolarCoin se pueden comprar o vender a través del contrato utilizando BNB:

- **Comprar DLC**: Los usuarios pueden comprar tokens DLC enviando BNB al contrato. El precio de DLC se ajusta dinámicamente en función de la cantidad de tokens disponibles en el contrato.
- **Vender DLC**: Los usuarios también pueden vender sus tokens DLC al contrato y recibir BNB a cambio.

### Comisión por Transacción
Se cobra una pequeña comisión por cada transacción de compra/venta para asegurar que el contrato mantenga suficiente liquidez para futuras transacciones.

## Cómo Interactuar con el Contrato

### Requisitos
Para interactuar con el contrato DolarCoin, necesitarás:
- Una billetera compatible con Binance Smart Chain (por ejemplo, MetaMask).
- Algo de BNB en tu billetera para las tarifas de gas y compras.

### Funciones Disponibles
1. **buyTokens()**: Permite a los usuarios comprar tokens DLC con BNB. El precio de DLC se ajusta dinámicamente después de cada compra.
2. **sellTokens()**: Permite a los usuarios vender sus tokens DLC al contrato a cambio de BNB.
3. **mineBlock()**: Permite a los usuarios minar tokens DLC resolviendo un rompecabezas criptográfico.
4. **getMiningReward()**: Devuelve la recompensa de minería disponible para el siguiente bloque.
5. **approve()**: Permite a los usuarios aprobar a un tercero para gastar tokens DLC en su nombre.
6. **transfer()**: Permite a los usuarios transferir tokens DLC a otra dirección.
7. **getTokensForBNB()**: Devuelve el número de tokens DLC que un usuario recibirá a cambio de una cantidad específica de BNB.
