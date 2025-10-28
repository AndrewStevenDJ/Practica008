# Assets de Imágenes

Este directorio contiene los recursos visuales para el ícono y splash screen de la app.

## Archivos Requeridos

### 1. icon.png
- **Tamaño recomendado**: 1024x1024 px
- **Formato**: PNG con fondo transparente
- **Uso**: Ícono principal de la aplicación
- **Sugerencia**: Logo de Pokédex o carta Pokémon

### 2. icon_foreground.png  
- **Tamaño recomendado**: 1024x1024 px
- **Formato**: PNG con fondo transparente
- **Uso**: Capa frontal del ícono adaptativo en Android
- **Nota**: Debe tener margen de seguridad (no usar bordes)

### 3. splash.png
- **Tamaño recomendado**: 1080x1920 px (o mayor)
- **Formato**: PNG
- **Uso**: Imagen central del splash screen
- **Sugerencia**: Logo o elemento representativo de la app

## Colores Utilizados

- **Color primario**: `#DC0A2D` (Rojo Pokémon)
- Puedes cambiar estos colores en `pubspec.yaml` en las secciones:
  - `flutter_launcher_icons.adaptive_icon_background`
  - `flutter_native_splash.color`

## Cómo Generar los Íconos y Splash

Después de agregar tus imágenes PNG en este directorio:

```bash
# Generar íconos
flutter pub run flutter_launcher_icons

# Generar splash screen
flutter pub run flutter_native_splash:create

# Limpiar splash screen (si es necesario)
flutter pub run flutter_native_splash:remove
```

## Recursos para Crear Íconos

- **Figma/Canva**: Para diseñar íconos personalizados
- **Flaticon**: Íconos gratuitos
- **Icons8**: Recursos de diseño
- **Pokémon Assets**: https://pokemondb.net/ (uso personal)

## Nota Importante

Las imágenes actuales son placeholders. Reemplázalas con tus propios diseños para personalizar la app.
