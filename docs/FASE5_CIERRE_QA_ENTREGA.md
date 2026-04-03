# Fase 5 - Cierre, QA y Entrega

Fecha de cierre tecnico: 03-Apr-2026

## 1) QA tecnico ejecutado

Comandos ejecutados en esta fase:

```bash
flutter analyze
flutter test
flutter build apk --release
```

Resultado:
- `flutter analyze`: sin issues.
- `flutter test`: aprobado.
- `flutter build apk --release`: APK generado correctamente.

Artefacto principal:
- `build/app/outputs/flutter-apk/app-release.apk` (release)

## 2) Checklist funcional por modulo (validacion manual)

Usar este checklist durante la grabacion del video.

### Modulos publicos
- [ ] Portada y navegacion principal.
- [ ] Registro de cuenta (`/auth/registro`).
- [ ] Activacion de cuenta (`/auth/activar`).
- [ ] Login (`/auth/login`).
- [ ] Olvidar contrasena (`/auth/olvidar`).
- [ ] Noticias (lista + detalle).
- [ ] Videos educativos.
- [ ] Catalogo (lista + filtro + detalle).
- [ ] Foro publico (lista + detalle lectura).
- [ ] Acerca de (datos de ambos integrantes).

### Modulos autenticados
- [ ] Refresh token (`/auth/refresh`).
- [ ] Perfil (`/perfil`) y cambio de foto (`/perfil/foto`).
- [ ] Vehiculos: crear, editar, subir foto, ver detalle y resumen.
- [ ] Mantenimientos: crear, listar, detalle, subir fotos.
- [ ] Combustible/Aceite: crear y listar.
- [ ] Gomas: consultar estado, actualizar estado, registrar pinchazo.
- [ ] Gastos: listar y registrar con categoria.
- [ ] Ingresos: listar y registrar.
- [ ] Foro autenticado: crear tema, responder, ver mis temas.

## 3) Icono final (criterio academico)

Estado:
- [x] Icono Android regenerado desde arte propio con tema automotriz + rostros.

Archivos relevantes:
- Fuente de icono: `assets/images/app_icon_square.png`
- Recursos Android regenerados:
  - `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - `android/app/src/main/res/drawable-*/ic_launcher_foreground.png`
  - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`

## 4) Guion sugerido para video demo

Duracion sugerida: 6 a 10 minutos.

Orden sugerido:
1. Presentacion breve del proyecto e integrantes.
2. Portada y navegacion.
3. Registro + activacion + login.
4. Modulos publicos (noticias, videos, catalogo, foro lectura, acerca de).
5. Modulos privados (perfil + vehiculos).
6. Fase 4 completa (mantenimientos, combustible, gomas, gastos/ingresos, foro autenticado).
7. Mostrar app instalada en Android y cierre.

Checklist rapido para grabar:
- Mostrar URL del repo: `https://github.com/luiscdano/AutomotricesITLA`
- Mostrar al menos 1 flujo exitoso por cada modulo obligatorio.
- Evitar cortes donde parezca que se omiten modulos.

## 5) Estructura recomendada del PDF final

1. Portada.
2. Objetivo del proyecto.
3. Integrantes (fotos, matriculas, contactos).
4. Arquitectura y stack tecnico (Flutter + API).
5. Evidencias por modulo (capturas con descripcion).
6. Evidencia de QA (analyze/test/build release).
7. Link del repositorio.
8. Link del video.
9. Codigo QR del video.
10. Conclusiones.

## 6) Preparacion del QR del video

Opciones:
- Opcion A: usar generador web (rapido).
- Opcion B: generar QR desde herramienta local y guardar PNG para insertar en PDF.

Dato que debe codificar el QR:
- URL final publica del video (YouTube u otra plataforma).

## 7) Checklist final de entrega academica

- [ ] APK release probado en Android.
- [ ] Repositorio GitHub actualizado.
- [ ] Video subido y publico.
- [ ] PDF final exportado.
- [ ] QR del video insertado en PDF.
- [ ] Verificacion cruzada entre ambos integrantes antes de enviar.
