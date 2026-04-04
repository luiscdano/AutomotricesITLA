# AutomotricesITLA

Proyecto final de la materia Introduccion al Desarrollo de Aplicaciones Moviles (ITLA, Trimestre 1-2026).

## Integrantes

- Luis Emilio Cedano (Matricula 2024-0128)
- Rafael J. Silfa (Matricula 2024-0034)

## Objetivo de este README

Este documento sera la guia operativa del proyecto para:

- Tener claro lo que pide el profesor (funcional, tecnico y entregables).
- Auditar lo que realmente expone la API.
- Registrar lo que ya se hizo y lo que se hara por fases.
- Revisar/validar fase por fase antes de avanzar.

## Fuentes auditadas (02-Apr-2026)

- Instrucciones oficiales: `https://taller-itla.ia3x.com/instrucciones`
- API base: `https://taller-itla.ia3x.com/api/`
- Swagger UI: `https://taller-itla.ia3x.com/api/swagger/`
- OpenAPI JSON: `https://taller-itla.ia3x.com/api/swagger/openapi.json`
- Ejemplos de codigo: `https://taller-itla.ia3x.com/api/swagger/ejemplos.html`

## Estado actual del repositorio

- Repositorio GitHub enlazado: `https://github.com/luiscdano/AutomotricesITLA`
- Rama principal local sincronizada con `origin/main`.
- Archivo base encontrado: `.gitignore` (orientado a Flutter).

## Auditoria tecnica del API (resultado)

## 1) Reglas de contrato confirmadas

- La API trabaja solo con `GET` y `POST`.
- En `POST`, el JSON se envia dentro de un campo `datax` (form-encoded o multipart).
- Endpoints con archivos usan `multipart/form-data`.
- Seguridad por `Authorization: Bearer <token>` para endpoints protegidos.
- Foto de perfil, foto de vehiculo y fotos de mantenimiento permiten archivos grandes de entrada, pero el servidor optimiza imagen final (referencia: instrucciones y descripciones OpenAPI).

## 2) Smoke tests ejecutados contra el servidor

- `GET /api/` responde `200` con metadata de servicio.
- `GET /api/noticias` sin token responde `401`.
- `GET /api/videos` sin token responde `401`.
- `GET /api/catalogo` sin token responde `401`.
- `GET /api/publico/foro` sin token responde `200`.
- `GET /api/publico/foro/detalle?id=1` sin token responde `200`.
- `POST /api/auth/login` enviando JSON directo responde `400`.
- `POST /api/auth/login` enviando `datax` form-encoded procesa solicitud (respuesta de negocio, no de formato).

Conclusion tecnica: para cumplir de forma robusta, debemos tratar `datax` como obligatorio en todos los `POST` y manejar autenticacion antes de consumir catalogo/noticias/videos.

## 3) Inconsistencias detectadas (importante)

1. Instrucciones vs OpenAPI en modulos "sin login":
- En instrucciones, Noticias, Videos y Catalogo aparecen en bloque "Sin Login".
- En OpenAPI y en pruebas reales, esos endpoints devuelven `401` sin token.

2. Endpoints publicos de foro:
- Instrucciones usan `GET /publico/foro` y `GET /publico/foro/detalle?id=`.
- Esos endpoints funcionan en produccion.
- No aparecen documentados en `openapi.json`.

3. Riesgo de implementacion:
- Si se codifica solo en base a instrucciones, faltaria manejo de autenticacion para rutas que hoy estan protegidas.
- Si se codifica solo en OpenAPI, faltarian endpoints publicos de foro que si existen.

Mitigacion acordada para el proyecto:
- Implementar segun comportamiento real del servidor y dejar fallback por si el profesor actualiza API.
- Revisar `https://taller-itla.ia3x.com/update` antes de cierres de fase para detectar cambios del backend.

## Alcance funcional obligatorio (15 modulos)

## A. Modulos sin login (segun guia docente)

1. Inicio/Dashboard (slider + mensajes + accesos rapidos).
2. Registro y activacion de cuenta.
3. Noticias automotrices.
4. Videos educativos.
5. Catalogo de vehiculos.
6. Foro comunitario en modo lectura.
7. Acerca de (datos completos de ambos integrantes).

## B. Modulos con login

8. Login, olvidar clave, refresh token.
9. Mi perfil + cambio de foto (camara/galeria).
10. Mis vehiculos (CRUD parcial + foto + resumen financiero).
11. Mantenimientos (incluye hasta 5 fotos).
12. Combustible y aceite.
13. Estado de gomas + pinchazos.
14. Gastos e ingresos.
15. Foro participativo (crear tema, responder, mis temas).

## Inventario API auditado (OpenAPI + pruebas)

Total operaciones OpenAPI: 38 (`19 GET`, `19 POST`).

### Publicos (sin header Bearer)

- `POST /auth/registro`
- `POST /auth/activar`
- `POST /auth/login`
- `POST /auth/olvidar`
- `POST /auth/refresh`
- `GET /imagen?path=...`
- `GET /publico/foro` (no aparece en OpenAPI, validado en runtime)
- `GET /publico/foro/detalle?id=...` (no aparece en OpenAPI, validado en runtime)

### Protegidos (requieren Bearer)

- `GET /perfil`
- `POST /perfil/foto`
- `GET /vehiculos`
- `POST /vehiculos`
- `GET /vehiculos/detalle`
- `POST /vehiculos/editar`
- `POST /vehiculos/foto`
- `GET /mantenimientos`
- `POST /mantenimientos`
- `GET /mantenimientos/detalle`
- `POST /mantenimientos/fotos`
- `GET /combustibles`
- `POST /combustibles`
- `GET /gomas`
- `POST /gomas/actualizar`
- `POST /gomas/pinchazos`
- `GET /gastos/categorias`
- `GET /gastos`
- `POST /gastos`
- `GET /ingresos`
- `POST /ingresos`
- `GET /foro/temas`
- `GET /foro/detalle`
- `POST /foro/crear`
- `POST /foro/responder`
- `GET /foro/mis-temas`
- `GET /noticias`
- `GET /noticias/detalle`
- `GET /videos`
- `GET /catalogo`
- `GET /catalogo/detalle`
- `POST /auth/cambiar-clave`

## Lo que se necesita (tecnico y de entrega)

## Desarrollo

- Android Studio (SDK Android) + emulador/dispositivo fisico.
- Flutter SDK (recomendado por estructura actual del repo).
- JDK compatible con toolchain de Flutter/Android.
- Git + GitHub.
- Manejo de camara/galeria y permisos Android.
- Cliente HTTP con soporte `multipart/form-data` y `application/x-www-form-urlencoded`.
- Almacenamiento local seguro para `token` y `refreshToken`.

## Entrega academica

- APK funcional.
- Codigo fuente en GitHub (este repo).
- Video demostrativo (YouTube u otra plataforma).
- PDF final con:
  - Portada.
  - Capturas de todos los modulos.
  - Datos y fotos de integrantes.
  - Link del repo.
  - Link del video.
  - QR del video.

## Penalizaciones a evitar

- `-5` si el icono no incluye tema vehicular y rostros de desarrolladores.
- `-5` si se encubre un integrante que no colaboro.
- Maximo `18/20` si se entrega individual.
- `0` por plagio.

## Plan por fases (controlado y validable)

## Fase 0 - Auditoria y plan (COMPLETADA)

Objetivo:
- Entender 100% de requerimientos y API real.

Hecho:
- Conexiones GitHub listas.
- Recoleccion y lectura completa de fuentes oficiales.
- Auditoria de inconsistencias y pruebas de smoke.
- Documento maestro inicial (este README).

Entregable de fase:
- README con alcance, riesgos y plan.

## Fase 1 - Base del proyecto + arquitectura + autenticacion (COMPLETADA)

Objetivo:
- Dejar la base tecnica lista para construir modulos rapido y sin deuda.

Hecho:
- Proyecto Flutter Android creado en el repo.
- Arquitectura base creada:
  - `lib/core` (configuracion, red, errores, resultado, almacenamiento).
  - `lib/features/auth` (data/domain/presentation).
  - `lib/shared/widgets` (componentes reutilizables).
- Cliente API central implementado:
  - `baseUrl` configurable por `--dart-define=API_BASE_URL`.
  - soporte `GET`, `POST datax`, y `multipart`.
  - header Bearer automatico en rutas protegidas.
  - parse de respuesta estandar `{success,message,data}`.
  - manejo de errores por status HTTP y errores de negocio.
- Capa de autenticacion implementada:
  - Registro (`/auth/registro`).
  - Activacion (`/auth/activar`).
  - Login (`/auth/login`).
  - Olvidar (`/auth/olvidar`).
  - Refresh (`/auth/refresh`).
  - Logout local (limpieza segura de tokens).
  - Perfil autenticado (`/perfil`) para restaurar y sincronizar sesion.
- Persistencia segura de `token` y `refreshToken` con `flutter_secure_storage`.
- Navegacion inicial implementada con `AuthGate`:
  - Publico si no hay sesion.
  - Autenticado si hay sesion valida.
  - restauracion de sesion al iniciar la app.
- UI funcional de Fase 1:
  - pantalla publica base.
  - login.
  - registro + activacion.
  - olvidar contrasena.
  - home autenticado con acciones de refresh/sync/logout.
- Ajustes Android:
  - permiso `INTERNET`.
  - nombre visible de app: `Automotrices ITLA`.
- Validacion tecnica ejecutada:
  - `flutter analyze` sin errores.
  - `flutter test` aprobado.

Criterio de aceptacion:
- Usuario puede registrarse/activar/login.
- Token queda persistido y se envia automaticamente a endpoints protegidos.
- App redirige correctamente al menu segun sesion.

## Fase 2 - Modulos publicos y navegacion principal (COMPLETADA)

Objetivo:
- Completar experiencia base sin depender del flujo completo privado.

Hecho:
- Arquitectura publica implementada en `lib/features/public`:
  - `data/public_repository.dart`
  - `data/public_repository_impl.dart`
  - `models/public_models.dart`
  - `presentation/screens/*`
- Estrategia de consumo API implementada para inconsistencias del backend:
  - Noticias y videos primero via `/publico/noticias` y `/publico/videos`.
  - Fallback a rutas protegidas cuando aplica.
  - Catalogo y detalle con fallback autenticado (`/catalogo`, `/catalogo/detalle`).
  - Foro en lectura publica (`/publico/foro`, `/publico/foro/detalle`).
- Dashboard/hub visual completado con accesos directos a:
  - Noticias (lista + detalle HTML).
  - Videos educativos.
  - Catalogo (filtros marca/modelo/anio + detalle).
  - Foro publico en lectura.
  - Acerca de equipo (fotos locales, matriculas y contactos).
- Navegacion integrada:
  - Acceso a hub publico desde portada (icono superior).
  - Acceso a hub publico desde home autenticado.
- UI consistente aplicada en modulos de Fase 2:
  - Fondo oscuro, textos claros, acentos marron/crema.
  - Estados `loading`, `error` y `empty` en todos los modulos.
- Dependencias y recursos agregados:
  - `flutter_html`, `intl`, `url_launcher`.
  - `assets/team/luis.png`, `assets/team/rafael.png`.
- Validacion tecnica de fase:
  - `flutter pub get` ejecutado.
  - `dart format lib` ejecutado.
  - `flutter analyze` sin errores.
  - `flutter test` aprobado.
  - Nota: en el entorno local el emulador Android ha estado intermitente; la app compila y corre correctamente en ejecución de Flutter, pero si vuelve a fallar ADB se recomienda reiniciar el AVD.

Criterio de aceptacion (estado):
- Cumplido: todos los modulos implementados con consumo real del API y manejo `loading/error/empty`.
- Excepcion controlada: en el backend actual, algunos recursos marcados como publicos requieren sesion; la app muestra mensaje claro y permite continuar tras login.

## Fase 3 - Perfil y vehiculos (nucleo de datos del usuario) (COMPLETADA)

Hecho:
- Arquitectura privada implementada en `lib/features/private`:
  - `data/private_repository.dart`
  - `data/private_repository_impl.dart`
  - `models/private_models.dart`
  - `presentation/screens/*`
- Mi perfil implementado:
  - lectura de perfil autenticado (`GET /perfil`).
  - cambio de foto con camara/galeria (`POST /perfil/foto` multipart).
  - visualizacion de matricula, correo, rol, grupo y fecha de registro.
- Mis vehiculos implementado:
  - listado con filtros locales por marca/modelo (`GET /vehiculos`).
  - registro de vehiculo con foto opcional (`POST /vehiculos` multipart).
  - edicion de datos (`POST /vehiculos/editar`).
  - cambio de foto de vehiculo (`POST /vehiculos/foto` multipart).
  - detalle con resumen financiero (`GET /vehiculos/detalle?id=...`).
- UI Fase 3 integrada:
  - `AuthenticatedHomeScreen` actualizado con acceso directo a hub privado.
  - `PrivateHubScreen` con accesos a Perfil y Vehiculos.
  - estilo consistente oscuro con estados `loading/error/empty`.
- Soporte de imagenes y permisos:
  - dependencia `image_picker` agregada.
  - permiso Android `CAMERA` agregado en `AndroidManifest.xml`.
- Validacion tecnica de fase:
  - `flutter pub get` ejecutado.
  - `dart format lib` ejecutado.
  - `flutter analyze` sin errores.
  - `flutter test` aprobado.

Criterio de aceptacion (estado):
- Cumplido: el usuario puede administrar sus vehiculos (crear/editar/foto) y ver resumen financiero por vehiculo.

## Fase 4 - Operaciones del vehiculo + foro autenticado (COMPLETADA)

Hecho:
- Capa de datos privada ampliada con endpoints de Fase 4 en `PrivateRepository`:
  - Mantenimientos: `GET /mantenimientos`, `POST /mantenimientos`, `GET /mantenimientos/detalle`, `POST /mantenimientos/fotos`.
  - Combustible/Aceite: `GET /combustibles`, `POST /combustibles`.
  - Gomas/Pinchazos: `GET /gomas`, `POST /gomas/actualizar`, `POST /gomas/pinchazos`.
  - Finanzas: `GET /gastos/categorias`, `GET/POST /gastos`, `GET/POST /ingresos`.
  - Foro autenticado: `GET /foro/temas`, `GET /foro/detalle`, `POST /foro/crear`, `POST /foro/responder`, `GET /foro/mis-temas`.
- Modelos privados agregados para Fase 4:
  - `MaintenanceRecord`, `FuelRecord`, `TireState`, `TireStatus`, `TirePuncture`,
  - `ExpenseCategory`, `ExpenseRecord`, `IncomeRecord`,
  - `PrivateForumTopic`, `PrivateForumDetail`, `PrivateForumReply`.
- UI Fase 4 implementada:
  - `VehicleOperationsScreen` con 4 modulos por vehiculo:
    - Mantenimientos (listar, filtrar, crear, detalle, subir fotos).
    - Combustible/Aceite (listar, filtrar por tipo, crear registro).
    - Gomas (ver estado por posicion, actualizar estado, registrar pinchazo).
    - Finanzas (gastos, ingresos, balance, registrar gasto e ingreso).
  - `AuthenticatedForumScreen`:
    - temas abiertos,
    - mis temas,
    - crear nuevo tema ligado a un vehiculo del usuario.
  - `AuthenticatedForumDetailScreen`:
    - detalle del tema,
    - lista de respuestas,
    - composer para responder en tiempo real.
- Navegacion privada actualizada:
  - `PrivateHubScreen` ahora incluye accesos a:
    - Mi perfil,
    - Mis vehiculos,
    - Operaciones del vehiculo,
    - Foro autenticado.
  - `AuthenticatedHomeScreen` actualizado para indicar acceso a Fases 3 y 4.
- Validacion tecnica de fase:
  - `dart format` ejecutado.
  - `flutter analyze` sin issues.
  - `flutter test` aprobado.

Criterio de aceptacion (estado):
- Cumplido: flujo operativo completo sobre vehiculos autenticados y participacion activa en foro autenticado (crear tema + responder + mis temas).

## Fase 5 - Cierre, QA y entrega (COMPLETADA)

Hecho:
- QA tecnico final ejecutado:
  - `flutter analyze` sin issues.
  - `flutter test` aprobado.
  - `flutter build apk --release` generado correctamente.
- Artefacto release generado:
  - `build/app/outputs/flutter-apk/app-release.apk` (APK final Android).
- Icono final del proyecto aplicado para Android (tema automotriz + rostros):
  - fuente: `assets/images/app_icon_square.png`.
  - recursos regenerados en `android/app/src/main/res/*`.
- Dependencia de generacion de iconos incorporada:
  - `flutter_launcher_icons` en `dev_dependencies`.
  - configuracion en `pubspec.yaml` orientada a Android.
- Script de cierre automatizado agregado:
  - `scripts/release_check.sh` (analyze + test + build release).
- Documentacion de entrega agregada:
  - `docs/FASE5_CIERRE_QA_ENTREGA.md` con:
    - checklist funcional completo por modulos,
    - guion sugerido para video,
    - estructura recomendada del PDF final,
    - checklist final de entrega academica.
  - `docs/QA_EVIDENCIA_2026-04-03.md` con evidencia resumida de analyze/test/build.

Criterio de aceptacion (estado):
- Cumplido: base tecnica cerrada, APK release generado, icono final aplicado y checklist/documentacion de entrega listos para completar video + PDF + QR.

## Matriz de estado (viva)

- [x] Fase 0 completada.
- [x] Fase 1 completada.
- [x] Fase 2 completada.
- [x] Fase 3 completada.
- [x] Fase 4 completada.
- [x] Fase 5 completada.

## Decisiones tecnicas recomendadas

- Usar Flutter como stack principal (alineado con `.gitignore` y ejemplos del profesor).
- Implementar una sola capa de transporte HTTP reusable para todos los modulos.
- No hardcodear texto ni endpoints; centralizar constantes.
- Preparar modelo de errores comun para todos los responses del backend.

## Proximo paso para validacion del equipo

Finalizar evidencias manuales de entrega:
- grabar y publicar video demo,
- generar PDF final con capturas,
- insertar QR del video en el PDF,
- validar checklist final en `docs/FASE5_CIERRE_QA_ENTREGA.md`.
