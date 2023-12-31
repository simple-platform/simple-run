use std::sync::Arc;

use tauri::{AppHandle, Manager, Window};

use crate::ERR_INVALID_CASE;

#[derive(Clone, serde::Serialize)]
struct AppInfo {
    org: String,
    repo: String,
    file_to_run: String,
}

fn get_app_info(request: &String) -> Result<AppInfo, &'static str> {
    let req = request.to_lowercase();

    if !req.starts_with("simplerun:gh?") {
        return Err("Invalid application run request");
    }

    let code = req.replace("simplerun:gh?", "");
    let parts = code.split('&');

    let mut org = String::new();
    let mut repo = String::new();
    let mut file_to_run = "".to_string();

    for part in parts {
        let kvp: Vec<&str> = part.split('=').collect();
        if kvp.len() != 2 {
            continue;
        }

        match kvp[0] {
            "o" => {
                org = kvp[1].trim().to_string();
            }
            "r" => {
                repo = kvp[1].trim().to_string();
            }
            "f" => {
                file_to_run = kvp[1].trim().to_string();
            }
            _ => {}
        }
    }

    if org.is_empty() || repo.is_empty() {
        return Err("Missing organization or repository");
    }

    Ok(AppInfo {
        org,
        repo,
        file_to_run,
    })
}

pub fn handle_run_request(app: Arc<AppHandle>, main_window: Arc<Window>, request: String) {
    if request.is_empty() {
        return;
    }

    match get_app_info(&request) {
        Ok(app_info) => match main_window.is_visible() {
            Ok(true) => {
                let _ = main_window.set_focus();
                app.emit_all("run-requested", app_info).unwrap();
            }
            Ok(false) => {
                let _ = main_window.show();
                app.emit_all("run-requested", app_info).unwrap();
            }
            Err(_) => unimplemented!("{}", ERR_INVALID_CASE),
        },
        Err(err) => {
            app.emit_all("run-request-failed", format!("{}: {}", err, request))
                .unwrap();
        }
    }
}
