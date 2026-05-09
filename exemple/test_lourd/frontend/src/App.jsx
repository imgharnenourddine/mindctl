import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Bar, Doughnut } from 'react-chartjs-2';
import { Chart as ChartJS, registerables } from 'chart.js';
import { Database, BarChart3, AlertTriangle, Brain, RefreshCw } from 'lucide-react';

ChartJS.register(...registerables);

// --- COMPOSANT AJOUTÉ : StatsView ---
const StatsView = () => {
  const [stats, setStats] = React.useState('');
  const [chartData, setChartData] = React.useState(null);

  React.useEffect(() => {
    axios.get('/api/stats').then(res => {
      setStats(res.data.stats);
      // Parser les nulls depuis last_data.txt
      const lignes = res.data.stats.split('\n');
      const labels = [];
      const nulls  = [];
      
      lignes.forEach(ligne => {
        const matchCol  = ligne.match(/Colonne (\w+)/);
        const matchNull = ligne.match(/nulls=(\d+)/);
        if (matchCol && matchNull) {
          labels.push(matchCol[1]);
          nulls.push(parseInt(matchNull[1]));
        }
      });

      setChartData({
        labels,
        datasets: [{
          label: 'Valeurs nulles par colonne',
          data: nulls,
          backgroundColor: nulls.map(n =>
            n > 5 ? '#ef4444' : '#10b981'
          )
        }]
      });
    });
  }, []);

  return (
    <div>
      <h2 style={{ color: '#3b82f6', marginBottom: '20px' }}>
        📊 Statistiques des données
      </h2>
      {chartData && (
        <div style={{ ...cardStyle, marginBottom: '20px' }}>
          <h3>Valeurs nulles par colonne</h3>
          <Bar
            data={chartData}
            options={{
              responsive: true,
              plugins: {
                legend: { display: false }
              },
              scales: {
                x: { ticks: { color: '#94a3b8' } },
                y: { ticks: { color: '#94a3b8' } }
              }
            }}
          />
        </div>
      )}
      <div style={cardStyle}>
        <h3>Rapport complet analyzer</h3>
        <pre style={{
          whiteSpace: 'pre-wrap',
          fontSize: '13px',
          color: '#94a3b8',
          background: '#05050a',
          padding: '15px',
          borderRadius: '8px',
          maxHeight: '400px',
          overflowY: 'auto'
        }}>
          {stats}
        </pre>
      </div>
    </div>
  );
};

// --- APPLICATION PRINCIPALE ---
const App = () => {
  const [view, setView] = useState('data');
  const [tables, setTables] = useState([]);
  const [selectedTable, setSelectedTable] = useState('');
  const [tableData, setTableData] = useState(null);
  const [conflits, setConflits] = useState([]);
  const [insight, setInsight] = useState('');

  useEffect(() => {
    axios.get('/api/tables').then(res => setTables(res.data.tables));
    axios.get('/api/depguard').then(res => setConflits(res.data.conflits));
    axios.get('/api/insight').then(res => setInsight(res.data.correlation));
  }, []);

  const loadTable = (name) => {
    setSelectedTable(name);
    axios.get(`/api/csv/${name}`).then(res => setTableData(res.data));
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#0a0a0f', color: '#e2e8f0', fontFamily: 'sans-serif' }}>
      {/* Sidebar */}
      <div style={{ width: '260px', background: '#11111a', borderRight: '1px solid #1e1e2d', padding: '20px' }}>
        <h2 style={{ color: '#3b82f6', display: 'flex', alignItems: 'center', gap: '10px' }}><Brain /> mindctl</h2>
        <p style={{ fontSize: '12px', color: '#64748b', marginBottom: '30px' }}>Mode Threads — 50 Tables</p>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <button onClick={() => setView('data')} style={btnStyle}><Database size={18}/> Données</button>
          <button onClick={() => setView('stats')} style={btnStyle}><BarChart3 size={18}/> Statistiques</button>
          <button onClick={() => setView('depguard')} style={btnStyle}><AlertTriangle size={18}/> Conflits ({conflits.length})</button>
          <button onClick={() => setView('insight')} style={btnStyle}><Brain size={18}/> Insights LLM</button>
        </nav>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, padding: '30px', overflowY: 'auto' }}>
        {view === 'data' && (
          <div>
            <select onChange={(e) => loadTable(e.target.value)} style={selectStyle}>
              <option>Sélectionner une table (table_01 - table_50)</option>
              {tables.map(t => <option key={t} value={t}>{t}</option>)}
            </select>
            {tableData && (
              <div style={cardStyle}>
                <h3>{tableData.table} <span style={badgeStyle}>✅ {tableData.total_lignes} lignes</span></h3>
                <table style={tableStyle}>
                  <thead><tr>{tableData.colonnes.map(c => <th key={c} style={thStyle}>{c}</th>)}</tr></thead>
                  <tbody>{tableData.donnees.slice(0, 15).map((row, i) => (
                    <tr key={i}>{tableData.colonnes.map(c => <td key={c} style={tdStyle}>{row[c]}</td>)}</tr>
                  ))}</tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* --- VUE STATISTIQUES AJOUTÉE --- */}
        {view === 'stats' && (
          <StatsView />
        )}

        {view === 'depguard' && (
          <div style={{ display: 'grid', gap: '20px' }}>
            {conflits.map((c, i) => (
              <div key={i} style={{ ...cardStyle, borderLeft: `5px solid ${c.niveau === 'CRITIQUE' ? '#ef4444' : '#f59e0b'}` }}>
                <div style={{ color: c.niveau === 'CRITIQUE' ? '#ef4444' : '#f59e0b', fontWeight: 'bold' }}>{c.niveau}</div>
                <h4>{c.description}</h4>
                <p style={{ fontSize: '13px', color: '#94a3b8' }}>Fichier: {c.fichier}</p>
                <div style={diffStyle}>
                  <div style={{ color: '#ef4444' }}>- {c.ligne_avant}</div>
                  <div style={{ color: '#10b981' }}>+ {c.ligne_apres}</div>
                </div>
              </div>
            ))}
          </div>
        )}
        
        {view === 'insight' && (
          <div style={cardStyle}>
            <h3><Brain color="#3b82f6" /> Analyse Prédictive</h3>
            <div style={{ whiteSpace: 'pre-wrap', lineHeight: '1.6', background: '#05050a', padding: '20px', borderRadius: '8px' }}>
              {insight}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

// Styles extraits pour rester cohérent
const btnStyle = { display: 'flex', alignItems: 'center', gap: '10px', width: '100%', padding: '12px', background: 'transparent', border: 'none', color: '#94a3b8', textAlign: 'left', cursor: 'pointer', borderRadius: '6px' };
const cardStyle = { background: '#11111a', padding: '20px', borderRadius: '12px', border: '1px solid #1e1e2d' };
const selectStyle = { padding: '10px', background: '#11111a', color: 'white', border: '1px solid #1e1e2d', borderRadius: '6px', marginBottom: '20px', width: '300px' };
const badgeStyle = { background: '#10b98122', color: '#10b981', padding: '4px 8px', borderRadius: '4px', fontSize: '12px' };
const tableStyle = { width: '100%', borderCollapse: 'collapse', marginTop: '10px' };
const thStyle = { textAlign: 'left', padding: '12px', borderBottom: '2px solid #1e1e2d', color: '#64748b' };
const tdStyle = { padding: '12px', borderBottom: '1px solid #1e1e2d', fontSize: '14px' };
const diffStyle = { background: '#000', padding: '15px', borderRadius: '6px', fontFamily: 'monospace', marginTop: '10px' };

export default App;
