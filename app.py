from flask import Flask, render_template, request
import importlib

app = Flask(__name__)

AUDITS = {
    "password_policy": ("audits.password_policy", "Password Policy"),
    "firewall": ("audits.firewall", "Firewall"),
    "defender": ("audits.defender", "Windows Defender"),
    "secure_boot": ("audits.secure_boot", "Secure Boot"),
    "bitlocker": ("audits.bitlocker", "BitLocker")
}

def run_audit_module(key):
    module_path, friendly = AUDITS[key]
    module = importlib.import_module(module_path)
    res = module.run()
    return {
        "key": key,
        "name": res.get("name", friendly),
        "status": res.get("status", "UNKNOWN"),
        "details": res.get("details", ""),
        "remediation": res.get("remediation", "")
    }

@app.route("/")
def home():
    return render_template("home.html")

@app.route("/results")
def results():
    audit_key = request.args.get("audit")
    if audit_key == "all":
        results = [run_audit_module(k) for k in AUDITS]
    elif audit_key in AUDITS:
        results = [run_audit_module(audit_key)]
    else:
        results = []
    return render_template("results.html", results=results)

if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1", port=5000)
