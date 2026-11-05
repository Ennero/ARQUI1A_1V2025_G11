# Monitoreo de sensores con Angular, Python y MQTT

Proyecto de Arquitectura de Computadoras 1 organizado en Fase1 y Fase2. Combina adquisición de sensores, servicios Python, comunicación MQTT y paneles Angular; Fase2 añade una API Express para MongoDB y código ARM64.

## Requisitos

Node.js compatible con Angular 20, Python según requirements.txt de cada fase, broker MQTT, MongoDB y el hardware descrito en los manuales. Los controladores GPIO/I2C requieren la plataforma física prevista.

## Ejecución

Los comandos parten de la raíz del repositorio, salvo donde se indica otra terminal.

```bash
# Panel de Fase1
cd Fase1/client
npm ci
npm start

# Otra terminal, desde la raíz y en el equipo de sensores:
cd Fase1/server
python -m pip install -r requirements.txt
python main.py

# API adicional de Fase2, desde la raíz:
cd Fase2/server/api
npm ci
npm run dev
```

## Recorrido de demostración

Abrir la URL que muestra Angular (habitualmente http://localhost:4200). Configurar broker, base de datos y sensores en los archivos config de la fase elegida antes de iniciar el servidor. Fase2/client tiene su propio npm ci y npm start; no ejecutar ambos paneles en el mismo puerto simultáneamente.

## Organización

Carpetas de la entrega: [`Fase1/`](Fase1/), [`Fase2/`](Fase2/).

## Documentación por fase

- [Manual técnico Fase1](Fase1/docs/manual_tecnico.mkd).
- [Manual de usuario Fase1](Fase1/docs/manual_usuario.mkd).
- [Configuración del servidor Fase1](Fase1/server/docs/setup.md).
- [Manual técnico Fase2](Fase2/docs/manual_tecnico.mkd).
- [Manual de usuario Fase2](Fase2/docs/manual_usuario.mkd).
- [Configuración del servidor Fase2](Fase2/server/docs/setup.md).

## Alcance y límites

La adquisición de datos reales depende del hardware y de servicios externos al proceso web. No se incluyen cachés Angular ni instalaciones de dependencias. Revisar la configuración de la fase seleccionada; no mezclar sus componentes.

## Contexto y licencia

Trabajo académico o de aprendizaje conservado en el portafolio de [Enner Mendizabal](https://github.com/Ennero). Los créditos de los trabajos en grupo se conservan en sus entregas y manuales.

Consultar [LICENSE](LICENSE) para la licencia de la raíz. Las dependencias y los componentes con avisos o licencias propios conservan sus condiciones.

### Licencias declaradas por componente

La licencia de la raíz no sustituye las declaraciones de estos manifiestos:

- `Fase2/server/api/package.json`: `ISC`.
