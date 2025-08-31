# JSON to Enum (Godot Editor Plugin) by Filippo Casola

## 📝 Overview
This Godot Editor plugin allows developers to convert JSON keys into GDScript enums directly inside the editor.  
It’s designed as a lightweight utility for technical designers and programmers who want to quickly create typed enums from JSON data 
without manual copy-pasting and update them with just one click.

---

## ✨ Features
- 📂 JSON file selection – Pick a JSON file from your project folder  
- 📁 Output path selection – Choose where the generated `.gd` file should be created  
- 📝 Custom output name – Define the name of the enum script  
- 🔑 Subkey selection – Inspect the JSON structure and choose which subkey to use for enum values  
- ⚡ One-click generation – Creates a `.gd` file with an enum definition, ready to use in scripts  
- 🔄 Filesystem auto-refresh – Ensures the generated files appear in the FileSystem panel immediately  
- ✅ Toggle options – Enable/disable extra features with checkboxes  

---

## Installation
1. Copy the `json_to_enum` folder into your project’s `res://addons/` directory  
2. Enable the plugin in Project → Project Settings → Plugins
3. A new dock tab called JSON to Enum will appear in the editor  

---

## Usage
1. Select a JSON file with the Browse button  
2. Select an output folder for the generated script  
3. Enter the output script name  
4. Use the analyser to preview keys and pick the desired subkey  
5. Click Generate Enum  
6. A `.gd` file will be created with your enum definition, ready to use  

---

## Current Limitations
- Overwriting a file does not currently work  
- If the chosen file name ends with `.gd`, unexpected behavior may occur  
- Works only with string values (other data types will still generate a file, but not a valid enum)  

---
