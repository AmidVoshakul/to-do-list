import flask
import json
from flask import Flask, request, render_template

app = Flask(__name__)

# Функции для работы с задачами
def load_tasks():
    try:
        with open("tasks.json", "r") as file:
            return json.load(file)
    except FileNotFoundError:
        return []

def save_tasks(tasks):
    with open("tasks.json", "w") as file:
        json.dump(tasks, file)

tasks = load_tasks()  # Загружаем задачи при старте

@app.route("/")
def index():
    return render_template("index.html", tasks=tasks)

@app.route("/add", methods=["POST"])
def add_task():
    new_task = {"id": len(tasks) + 1, "text": request.form["text"], "done": False}
    tasks.append(new_task)
    save_tasks(tasks)  # Сохраняем изменения
    return render_template("tasks.html", tasks=tasks)

@app.route("/delete/<int:id>", methods=["POST"])
def delete_task(id):
    global tasks
    tasks = [task for task in tasks if task["id"] != id]
    save_tasks(tasks)  # Сохраняем изменения
    return render_template("tasks.html", tasks=tasks)

@app.route("/complete/<int:id>", methods=["POST"])
def complete_task(id):
    for task in tasks:
        if task["id"] == id:
            task["done"] = not task["done"]
    save_tasks(tasks)  # Сохраняем изменения
    return render_template("tasks.html", tasks=tasks)

@app.route("/filter")
def filter_tasks():
    status = request.args.get("status", "all")
    if status == "active":
        filtered_tasks = [task for task in tasks if not task["done"]]
    elif status == "completed":
        filtered_tasks = [task for task in tasks if task["done"]]
    else:
        filtered_tasks = tasks
    return render_template("tasks.html", tasks=filtered_tasks)

if __name__ == "__main__":
    app.run(debug=True)
