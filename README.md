# JSON to Enum Generator (Godot Plugin) by Filippo Casola

A lightweight Godot Editor plugin that converts **JSON keys into GDScript enums**.  
Useful for keeping enums in sync with external data and speeding up workflow.  

## ✨ Features
- 📂 Select JSON file & output folder directly in the editor  
- 📝 Custom output script name  
- 🔑 Pick which JSON subkey to use as enum values  
- ⚡ One-click generation of `.gd` enum file  
- 🔄 Auto refresh so new scripts appear instantly in FileSystem  
- ✅ Toggle options with checkboxes for flexibility  

## 🚀 Installation
1. Copy the `json_to_enum` folder into `res://addons/`  
2. Enable it in **Project → Project Settings → Plugins**  
3. Open the **JSON to Enum** dock tab  

## 🛠 Usage
1. Choose a JSON file  
2. Select output path & script name  
3. Pick a JSON subkey from the analyser  
4. Click **Generate Enum**  
5. Use your generated `.gd` enum in scripts  

## ⚠️ Current Limitations
- 🚫 Overwriting a file does not currently work  
- ⚠️ If the chosen file name ends with `.gd`, unexpected behavior may occur  
- 🔤 Works only with **string values** (other data types will still generate a file, but not a valid enum)
