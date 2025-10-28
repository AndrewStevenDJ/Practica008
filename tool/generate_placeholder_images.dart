import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Script para generar imágenes placeholder para ícono y splash
/// Ejecutar con: dart run tool/generate_placeholder_images.dart
void main() {
  print('🎨 Generando imágenes placeholder...');
  
  // Generar ícono 1024x1024
  generateIcon();
  
  // Generar ícono foreground 1024x1024
  generateIconForeground();
  
  // Generar splash 1080x1920
  generateSplash();
  
  print('✅ ¡Imágenes generadas exitosamente!');
  print('📁 Ubicación: assets/images/');
  print('💡 Reemplaza estas imágenes con tus propios diseños.');
}

void generateIcon() {
  // Crear imagen cuadrada 1024x1024 con fondo rojo Pokémon
  final image = img.Image(width: 1024, height: 1024);
  
  // Fondo rojo (#DC0A2D)
  img.fill(image, color: img.ColorRgb8(220, 10, 45));
  
  // Círculo blanco en el centro (estilo Pokéball)
  img.fillCircle(
    image,
    x: 512,
    y: 512,
    radius: 400,
    color: img.ColorRgb8(255, 255, 255),
  );
  
  // Círculo pequeño rojo en el centro
  img.fillCircle(
    image,
    x: 512,
    y: 512,
    radius: 150,
    color: img.ColorRgb8(220, 10, 45),
  );
  
  // Línea horizontal negra
  img.fillRect(
    image,
    x1: 0,
    y1: 482,
    x2: 1024,
    y2: 542,
    color: img.ColorRgb8(30, 30, 30),
  );
  
  // Guardar
  final file = File('assets/images/icon.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('✅ icon.png generado');
}

void generateIconForeground() {
  // Crear imagen con transparencia
  final image = img.Image(width: 1024, height: 1024);
  
  // Círculo blanco (más pequeño por el margen de seguridad)
  img.fillCircle(
    image,
    x: 512,
    y: 512,
    radius: 350,
    color: img.ColorRgb8(255, 255, 255),
  );
  
  // Círculo pequeño rojo en el centro
  img.fillCircle(
    image,
    x: 512,
    y: 512,
    radius: 120,
    color: img.ColorRgb8(220, 10, 45),
  );
  
  // Línea horizontal negra
  img.fillRect(
    image,
    x1: 150,
    y1: 482,
    x2: 874,
    y2: 542,
    color: img.ColorRgb8(30, 30, 30),
  );
  
  // Guardar con transparencia
  final file = File('assets/images/icon_foreground.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('✅ icon_foreground.png generado');
}

void generateSplash() {
  // Crear imagen 1080x1920
  final image = img.Image(width: 1080, height: 1920);
  
  // Fondo transparente (será rojo por la configuración)
  
  // Pokéball grande en el centro
  final centerX = 540;
  final centerY = 960;
  
  // Círculo blanco
  img.fillCircle(
    image,
    x: centerX,
    y: centerY,
    radius: 300,
    color: img.ColorRgb8(255, 255, 255),
  );
  
  // Círculo pequeño rojo en el centro
  img.fillCircle(
    image,
    x: centerX,
    y: centerY,
    radius: 100,
    color: img.ColorRgb8(220, 10, 45),
  );
  
  // Línea horizontal negra
  img.fillRect(
    image,
    x1: 200,
    y1: 930,
    x2: 880,
    y2: 990,
    color: img.ColorRgb8(30, 30, 30),
  );
  
  // Texto "PokéCard Dex"
  // (El texto real se puede agregar después con un editor de imágenes)
  
  // Guardar
  final file = File('assets/images/splash.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('✅ splash.png generado');
}
