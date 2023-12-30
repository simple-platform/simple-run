// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{
    AppHandle, CustomMenuItem, GlobalWindowEvent, Manager, SystemTray, SystemTrayEvent,
    SystemTrayMenu,
};

fn system_tray_event_handler(app: &AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::MenuItemClick { id, .. } => match id.as_str() {
            "dashboard" => {
                let window = app.get_window("main").unwrap();
                match window.is_visible() {
                    Ok(true) => {}
                    Ok(false) => {
                        let _ = window.show();
                    }
                    Err(_) => unimplemented!("This case is not possible!"),
                }
            }
            "quit" => app.exit(0),
            _ => {}
        },
        _ => {}
    }
}

fn window_event_handler(e: GlobalWindowEvent) {
    match e.event() {
        tauri::WindowEvent::CloseRequested { api, .. } => {
            e.window().hide().unwrap();
            api.prevent_close();
        }
        _ => {}
    }
}

fn main() {
    let dashboard_menu_item = CustomMenuItem::new("dashboard", "Open Dashboard");
    let quit_menu_item = CustomMenuItem::new("quit", "Quit Simple Run");

    let menu = SystemTrayMenu::new()
        .add_item(dashboard_menu_item)
        .add_native_item(tauri::SystemTrayMenuItem::Separator)
        .add_item(quit_menu_item);

    let system_tray = SystemTray::new().with_menu(menu);

    tauri::Builder::default()
        .system_tray(system_tray)
        .on_system_tray_event(system_tray_event_handler)
        .on_window_event(window_event_handler)
        .run(tauri::generate_context!())
        .expect("Error while running Simple Run.");
}
