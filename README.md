# Pokémon Cart App

Pokémon Cart App es una aplicación móvil desarrollada en Flutter que simula la experiencia de comprar/capturar, integrando funcionalidades nativas para enriquecer la interacción. El usuario puede navegar por un catálogo paginado de Pokémon, añadirlos a un carrito de compras y gestionar sus capturas incluso sin conexión a internet. Al volver a estar conectado, los cambios se sincronizan automáticamente.

La app incorpora **feedback háptico** y **geolocalización** para ofrecer una experiencia similar a la de un juego o Pokédex: cada vez que agregas o eliminas un Pokémon, recibes una vibración y se registra el lugar y momento de la “captura”. Esto aporta realismo y contexto, haciendo que cada acción sea memorable y personalizada.

El proyecto está diseñado con una arquitectura escalable y modular, siguiendo buenas prácticas de desarrollo y asegurando un rendimiento óptimo, facilidad de mantenimiento y una experiencia de usuario atractiva y accesible.

---

## Tabla de contenidos

1. [Características](#características)
2. [Arquitectura y estructura](#arquitectura-y-estructura)
3. [Funcionalidad nativa](#funcionalidad-nativa)
4. [Notas sobre feedback háptico en Android](#notas-sobre-feedback-háptico-en-android)
5. [Tecnologías y librerías](#tecnologías-y-librerías)
6. [Instalación y ejecución](#instalación-y-ejecución)
7. [Decisiones técnicas](#decisiones-técnicas)
8. [Diseño & UX](#diseño--ux)

---

## Características

| Módulo           | Descripción                                                                                                                          |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Catálogo         | • Lista paginada desde PokéAPI<br>• Imagen, nombre y código de Pokémon<br>• Botón “Agregar al carrito” en forma de pokeball          |
| Carrito          | • Lista granular (header, AnimatedList y footer)<br>• Eliminación optimista con animación Slide/Fade<br>• Totales y conteo reactivos |
| Offline first    | • Almacén local con Hive <br>• App usable sin conexión                                                                               |
| Sincronización   | • Al reconectarse, se envían cambios pendientes y se muestra notificación de éxito                                                   |
| Feedback háptico | • Vibración ligera al agregar/eliminar ítems                                                                                         |
| Geolocalización  | • Guarda la ubicación y la hora de la compra/captura                                                                                 |
| Rendimiento      | • Keys únicas, AnimatedList y `BlocSelector` → rebuild mínimo                                                                        |

---

## Arquitectura y estructura

La arquitectura sigue el enfoque Clean Architecture con BLoC para gestión de estado. Esto permite separar claramente la lógica de negocio, la persistencia y la presentación, facilitando la escalabilidad y el mantenimiento. Cada capa tiene responsabilidades bien definidas y los datos fluyen de manera controlada entre ellas, asegurando que la UI sea reactiva y eficiente.

```
lib/
 ├─ core/                       # Infraestructura común
 │   ├─ constants/              # Constantes globales (API URLs, colores por tipo)
 │   ├─ errors/                 # Clases/error-handling reutilizable
 │   ├─ services/               # Servicios nativos: vibración, geolocalización, sincronización
 │   └─ utils/                  # Helpers y extensiones
 ├─ data/                       # Capa de datos (fuentes externas + persistencia)
 │   ├─ datasources/            # Orígenes (remoto → PokéAPI, local → Hive)
 │   ├─ models/                 # DTO / serialización JSON
 │   └─ repositories/           # Implementaciones concretas de repositorios
 ├─ domain/                     # Reglas de negocio puras
 │   ├─ entities/               # Entidades: Pokémon, CartItem…
 │   ├─ repositories/           # Interfaces abstractas
 │   └─ usecases/               # Casos de uso (p. ej. GetPokemonList)
 ├─ presentation/               # Capa UI
 │   ├─ bloc/                   # BLoCs + eventos/estados
 │   ├─ pages/                  # Pantallas (catalog_page, cart_page)
 │   └─ widgets/                # Componentes reutilizables (cards, headers, lists…)
 └─ main.dart                   # Punto de entrada de la aplicación
```

---

## Funcionalidad nativa

He elegido implementar **feedback háptico** (vibración) y **geolocalización** porque se complementan para aportar valor directo a la experiencia del usuario en una app de carrito de Pokémon.  
La vibración refuerza la sensación de acción inmediata al agregar o eliminar ítems, mientras que la geolocalización guarda el lugar y momento de la “captura”, simulando la experiencia de un juego o Pokédex.  
Ambas funcionalidades se integran de forma natural en el flujo de la app, sin requerir pasos extra ni permisos invasivos, y enriquecen la interacción y el contexto de uso.

- **Feedback háptico**

  - No requiere permisos especiales.
  - Refuerza la sensación de respuesta inmediata al usuario.
  - Se integra en los puntos críticos del flujo (add/remove item).
  - Implementación:
    - `HapticFeedback.lightImpact();` // al agregar
    - `HapticFeedback.mediumImpact();` // al eliminar

- **Geolocalización**
  - Aporta contexto: el usuario ve dónde “capturó” cada Pokémon.
  - Da una sensación de Pokedex a la aplicación.
  - Se integra sin fricción en el flujo normal (no requiere pasos extra).

---

## Notas sobre feedback háptico en Android

> La experiencia de vibración puede variar según el fabricante y configuración del dispositivo.  
> Si no percibes la vibración, revisa lo siguiente:

- **Samsung Galaxy:**  
  Verifica que la opción **Vibración del sistema** esté activada en Ajustes.

- **Xiaomi / MIUI:**  
  Ve a **Configuración → Sonido → Vibración adicional**  
  Activa **Vibración al tocar**.

- **OnePlus:**  
  Ve a **Configuración → Sonido → Vibración y feedback háptico**  
  Asegúrate de que la vibración esté habilitada.

---

## Tecnologías y librerías

| Propósito                     | Paquete (versión)                               |
| ----------------------------- | ----------------------------------------------- |
| **Red y conectividad**        | `dio`, `connectivity_plus`                      |
| **Gestión de estado**         | `flutter_bloc`, `equatable`                     |
| **UI / imágenes**             | `cached_network_image`                          |
| **Inyección de dependencias** | `get_it`                                        |
| **Geolocalización nativa**    | `geolocator`, `geocoding`, `permission_handler` |
| **Almacenamiento offline**    | `hive`, `hive_flutter`                          |
| **Íconos iOS**                | `cupertino_icons`                               |

---

## Instalación y ejecución

1. **Clona el proyecto**

   ```sh
   git clone https://github.com/jonathanvrag/pokemon_cart_app.git
   cd pokemon_cart_app
   ```

2. **Instala las dependencias**

   ```sh
   flutter pub get
   ```

3. **Genera los adaptadores Hive**

   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

   Esto crea los archivos `*.g.dart` necesarios para la base de datos local.

4. **Ejecuta la aplicación**

   ```sh
   flutter run
   ```

   - Selecciona un dispositivo desde la barra de dispositivos (VS Code / Android Studio) o usa `-d <deviceId>` en línea de comandos.
   - La app se abrirá en la pantalla Catálogo y podrás probar el flujo completo (offline incluido).

5. **Compila un APK de producción (opcional)**

   ```sh
   flutter build apk --release
   ```

   El instalador se guardará en `build/app/outputs/apk/release/app-release.apk`.

   > Para un IPA necesitarás macOS con Xcode (`flutter build ios --release`). No tuve la oportunidad de probarlo, solo cuento con SO Windows.

### Notas finales

- **Permisos**

  - Android: revisa `android/app/src/main/AndroidManifest.xml` (ubicación, Internet).
  - iOS: revisa `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`).

- **Variables de entorno**

  - No se necesitan claves API: la app consume la PokéAPI pública.

- **Modos de conexión**
  - El proyecto usa `connectivity_plus`: puedes activar el modo avión para comprobar el funcionamiento offline y la posterior sincronización al volver a conectarte.

---

## Decisiones técnicas

| Tema                   | Elección                                              | Motivo                                          |
| ---------------------- | ----------------------------------------------------- | ----------------------------------------------- |
| Arquitectura           | Clean + BLoC                                          | Aislamos dominio de UI, fácil testear.          |
| Almacenamiento         | Hive                                                  | Sincrónico, ligero, ideal para modo offline.    |
| Granularidad           | Widgets pequeños + `BlocSelector`                     | Evitar rebuilds globales y parpadeos.           |
| Eliminación optimizada | Lista local + `AnimatedList.removeItem`               | UX instantánea, BLoC confirma en segundo plano. |
| Sincronización         | Evento `SyncCart` al reconectar (`connectivity_plus`) | Transparente para el usuario.                   |

---

## Diseño & UX

- **Paleta** suave, colores pasteles.
- **Tipografía** `Roboto` por legibilidad.
- **Animaciones** Slide/Fade en listas y transiciones.
- **Accesibilidad** texto con contraste AA, botones grandes.
- **Responsive** layout adaptable a tablets.

---
