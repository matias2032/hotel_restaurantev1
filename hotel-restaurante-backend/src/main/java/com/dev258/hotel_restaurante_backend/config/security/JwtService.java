package com.dev258.hotel_restaurante_backend.config.security;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expiration-minutes:120}")
    private Long expirationMinutes;

    public String gerarToken(UsuarioEntity usuario) {
        Instant agora = Instant.now();
        Instant expiraEm = agora.plusSeconds(expirationMinutes * 60);

        Map<String, Object> header = new LinkedHashMap<>();
        header.put("alg", "HS256");
        header.put("typ", "JWT");

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("sub", usuario.getIdUsuario().toString());
        payload.put("nome", usuario.getNome());
        payload.put("email", usuario.getEmail());
        payload.put("perfil", usuario.getPerfil() != null ? usuario.getPerfil().getNomePerfil() : null);
        payload.put("iat", agora.getEpochSecond());
        payload.put("exp", expiraEm.getEpochSecond());

        String headerBase64 = base64Url(toJson(header));
        String payloadBase64 = base64Url(toJson(payload));

        String conteudo = headerBase64 + "." + payloadBase64;
        String assinatura = assinar(conteudo);

        return conteudo + "." + assinatura;
    }

    public Long extrairIdUsuario(String token) {
        Map<String, Object> payload = lerPayload(token);
        Object sub = payload.get("sub");

        if (sub == null) {
            throw new IllegalArgumentException("Token sem usuário.");
        }

        return Long.parseLong(sub.toString());
    }

    public boolean tokenValido(String token) {
        try {
            String[] partes = token.split("\\.");

            if (partes.length != 3) {
                return false;
            }

            String conteudo = partes[0] + "." + partes[1];
            String assinaturaEsperada = assinar(conteudo);

            if (!assinaturaEsperada.equals(partes[2])) {
                return false;
            }

            Map<String, Object> payload = lerPayload(token);
            Object exp = payload.get("exp");

            if (exp == null) {
                return false;
            }

            long expEpoch = Long.parseLong(exp.toString());

            return Instant.now().getEpochSecond() < expEpoch;
        } catch (Exception e) {
            return false;
        }
    }

    private Map<String, Object> lerPayload(String token) {
        String[] partes = token.split("\\.");

        if (partes.length != 3) {
            throw new IllegalArgumentException("Token inválido.");
        }

        String jsonPayload = new String(
                Base64.getUrlDecoder().decode(partes[1]),
                StandardCharsets.UTF_8
        );

        return fromJsonSimples(jsonPayload);
    }

    private String assinar(String conteudo) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec chave = new SecretKeySpec(
                    secret.getBytes(StandardCharsets.UTF_8),
                    "HmacSHA256"
            );

            mac.init(chave);

            byte[] assinatura = mac.doFinal(conteudo.getBytes(StandardCharsets.UTF_8));

            return Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(assinatura);
        } catch (Exception e) {
            throw new IllegalStateException("Erro ao assinar JWT.", e);
        }
    }

    private String base64Url(String valor) {
        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(valor.getBytes(StandardCharsets.UTF_8));
    }

    private String toJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder("{");

        boolean primeiro = true;

        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!primeiro) {
                json.append(",");
            }

            primeiro = false;

            json.append("\"").append(escape(entry.getKey())).append("\":");

            Object valor = entry.getValue();

            if (valor == null) {
                json.append("null");
            } else if (valor instanceof Number || valor instanceof Boolean) {
                json.append(valor);
            } else {
                json.append("\"").append(escape(valor.toString())).append("\"");
            }
        }

        json.append("}");

        return json.toString();
    }

    private Map<String, Object> fromJsonSimples(String json) {
        Map<String, Object> map = new LinkedHashMap<>();

        String conteudo = json.trim();

        if (conteudo.startsWith("{")) {
            conteudo = conteudo.substring(1);
        }

        if (conteudo.endsWith("}")) {
            conteudo = conteudo.substring(0, conteudo.length() - 1);
        }

        if (conteudo.isBlank()) {
            return map;
        }

        String[] pares = conteudo.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");

        for (String par : pares) {
            String[] partes = par.split(":", 2);

            if (partes.length != 2) {
                continue;
            }

            String chave = limparAspas(partes[0].trim());
            String valorRaw = partes[1].trim();

            Object valor;

            if ("null".equals(valorRaw)) {
                valor = null;
            } else if (valorRaw.startsWith("\"") && valorRaw.endsWith("\"")) {
                valor = limparAspas(valorRaw);
            } else {
                try {
                    valor = Long.parseLong(valorRaw);
                } catch (Exception e) {
                    valor = valorRaw;
                }
            }

            map.put(chave, valor);
        }

        return map;
    }

    private String limparAspas(String valor) {
        String texto = valor;

        if (texto.startsWith("\"")) {
            texto = texto.substring(1);
        }

        if (texto.endsWith("\"")) {
            texto = texto.substring(0, texto.length() - 1);
        }

        return texto.replace("\\\"", "\"");
    }

    private String escape(String valor) {
        return valor.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}