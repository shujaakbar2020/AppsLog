import React, { useEffect, useState } from "react";
import "./ContainerStatus.css";

export default function ContainerStatus() {
  const [meta, setMeta] = useState(null);
  const [error, setError] = useState(null);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const API_URL = process.env.REACT_APP_API_URL;
  const DATA_URL = process.env.REACT_APP_API_URL_DATA;

  useEffect(() => {
    document.title = "Docker Container Status";

    fetch(`http://${API_URL}/`) // GET container info
      .then((res) => {
        if (!res.ok) throw new Error("Failed to fetch API");
        return res.json();
      })
      .then((data) => setMeta(data))
      .catch((err) => setError(err.message));
  }, []);

  const handleSave = async () => {
    if (!meta) return;

    setSaving(true);
    setMessage("");

    try {
      const res = await fetch(`http://${DATA_URL}/save`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(meta),
      });

      if (!res.ok) throw new Error("Failed to save data");
      const data = await res.json();
      setMessage(data.message || "Data saved successfully!");
    } catch (err) {
      setMessage("Error saving data: " + err.message);
    } finally {
      setSaving(false);
    }
  };

  if (error) {
    return (
      <div className="wrapper">
        <p>Error: {error}</p>
      </div>
    );
  }

  if (!meta) {
    return (
      <div className="wrapper">
        <p>Loading container info...</p>
      </div>
    );
  }

  return (
    <div className="wrapper">
      <button className="save-button" onClick={handleSave} disabled={saving}>
        {saving ? "Saving..." : "Save"}
      </button>

      <div className="instance-card">
        <div className="instance-card__cnt">
          <div className="instance-card-inf">
            <div className="instance-card-inf__item">
              <div className="instance-card-inf__txt">Container ID</div>
              <div className="instance-card-inf__title">{meta.container_id}</div>
            </div>
            <div className="instance-card-inf__item">
              <div className="instance-card-inf__txt">Container Username</div>
              <div className="instance-card-inf__title">{meta.container_username}</div>
            </div>
            <div className="instance-card-inf__item">
              <div className="instance-card-inf__txt">Availability Zone</div>
              <div className="instance-card-inf__title">{meta.availability_zone}</div>
            </div>
          </div>
        </div>
      </div>

      {message && <p style={{ textAlign: "center", marginTop: "20px" }}>{message}</p>}
    </div>
  );
}
