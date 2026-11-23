package com.paco.piedrapapeltijera;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.OneArgFunction;
import org.luaj.vm2.lib.ZeroArgFunction;
import org.luaj.vm2.lib.jse.JsePlatform;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public class MainActivity extends Activity {

    private TextView consolaTexto;
    private EditText campoEntrada;
    private Button botonEnviar;
    private Globals globals;
    private LuaValue chunk;
    private String ultimaEntrada = "";
    private boolean esperandoEntrada = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout raiz = new LinearLayout(this);
        raiz.setOrientation(LinearLayout.VERTICAL);
        raiz.setPadding(24, 24, 24, 24);

        ScrollView scroll = new ScrollView(this);
        consolaTexto = new TextView(this);
        consolaTexto.setTextSize(16f);
        scroll.addView(consolaTexto);

        LinearLayout filaEntrada = new LinearLayout(this);
        filaEntrada.setOrientation(LinearLayout.HORIZONTAL);

        campoEntrada = new EditText(this);
        campoEntrada.setHint("Escribe aquí...");
        LinearLayout.LayoutParams paramsCampo = new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
        campoEntrada.setLayoutParams(paramsCampo);

        botonEnviar = new Button(this);
        botonEnviar.setText("Enviar");

        filaEntrada.addView(campoEntrada);
        filaEntrada.addView(botonEnviar);

        LinearLayout.LayoutParams paramsScroll = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f);
        raiz.addView(scroll, paramsScroll);
        raiz.addView(filaEntrada);

        setContentView(raiz);

        configurarLua();
        ejecutarScript();

        botonEnviar.setOnClickListener(v -> {
            ultimaEntrada = campoEntrada.getText().toString();
            campoEntrada.setText("");
            esperandoEntrada = false;
            escribirLinea("> " + ultimaEntrada);
        });
    }

    private void configurarLua() {
        globals = JsePlatform.standardGlobals();

        globals.set("print", new OneArgFunction() {
            @Override
            public LuaValue call(LuaValue arg) {
                escribirLinea(arg.tojstring());
                return NIL;
            }
        });

        globals.get("io").set("read", new ZeroArgFunction() {
            @Override
            public LuaValue call() {
                esperandoEntrada = true;
                while (esperandoEntrada) {
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException ignored) {
                    }
                }
                return LuaValue.valueOf(ultimaEntrada);
            }
        });
    }

    private void ejecutarScript() {
        new Thread(() -> {
            try {
                InputStream is = getAssets().open("main.lua");
                byte[] buffer = new byte[is.available()];
                int leido = is.read(buffer);
                is.close();
                String codigoLua = new String(buffer, 0, leido, StandardCharsets.UTF_8);

                chunk = globals.load(codigoLua, "main.lua");
                chunk.call();
            } catch (Exception e) {
                escribirLinea("Error al cargar main.lua: " + e.getMessage());
            }
        }).start();
    }

    private void escribirLinea(String texto) {
        runOnUiThread(() -> {
            consolaTexto.append(texto + "\n");
        });
    }
}
