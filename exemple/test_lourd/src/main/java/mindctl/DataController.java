package mindctl;

import org.springframework.web.bind.annotation.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.*;
import java.io.IOException;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:3000")
public class DataController {

    private final Path tmpDir = Paths.get("/tmp");
    private final Path logDir = Paths.get("/var/log/mindctl/reports");

    @GetMapping("/tables")
    public Map<String, List<String>> getTables() throws IOException {
        List<String> tables = Files.list(tmpDir)
            .map(p -> p.getFileName().toString())
            .filter(name -> name.startsWith("mindctl_") && name.endsWith("_clean.csv"))
            .map(name -> name.replace("mindctl_", "").replace("_clean.csv", ""))
            .sorted()
            .collect(Collectors.toList());
        return Collections.singletonMap("tables", tables);
    }

    @GetMapping("/csv/{table}")
    public Map<String, Object> getCsv(@PathVariable String table) throws IOException {
        Path path = tmpDir.resolve("mindctl_" + table + "_clean.csv");
        List<String> lines = Files.readAllLines(path);
        String[] headers = lines.get(0).split(",");
        List<Map<String, String>> data = lines.stream().skip(1).map(line -> {
            String[] values = line.split(",");
            Map<String, String> row = new HashMap<>();
            for (int i = 0; i < headers.length; i++) row.put(headers[i], values[i]);
            return row;
        }).collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("table", table);
        response.put("colonnes", headers);
        response.put("donnees", data);
        response.put("total_lignes", data.size());
        return response;
    }

    @GetMapping("/stats")
    public Map<String, String> getStats() throws IOException {
        Path path = logDir.resolve("last_data.txt");
        return Collections.singletonMap("stats", Files.exists(path) ? Files.readString(path) : "Analyse indisponible");
    }

    @GetMapping("/depguard")
    public Map<String, Object> getDepguard() throws IOException {
        Path path = logDir.resolve("last_depguard.txt");
        if (!Files.exists(path)) return Map.of("conflits", List.of(), "total", 0);
        
        String content = Files.readString(path);
        List<Map<String, String>> conflits = Arrays.stream(content.split("---"))
            .filter(s -> !s.isBlank())
            .map(block -> {
                Map<String, String> m = new HashMap<>();
                for (String line : block.trim().split("\n")) {
                    String[] parts = line.split(":", 2);
                    if (parts.length == 2) m.put(parts[0].trim().toLowerCase().replace(" ", "_"), parts[1].trim());
                }
                return m;
            }).collect(Collectors.toList());
        return Map.of("conflits", conflits, "total", conflits.size());
    }

    @GetMapping("/insight")
    public Map<String, String> getInsight() throws IOException {
        Optional<Path> lastInsight = Files.list(logDir)
            .filter(p -> p.getFileName().toString().startsWith("insight_"))
            .max(Comparator.comparingLong(p -> p.toFile().lastModified()));
        return Collections.singletonMap("correlation", lastInsight.isPresent() ? Files.readString(lastInsight.get()) : "Aucun insight LLM généré.");
    }
}
