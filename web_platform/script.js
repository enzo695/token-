document.addEventListener('DOMContentLoaded', () => {
    const copyBtn = document.getElementById('copyBtn');
    const bookmarkletCode = document.getElementById('bookmarkletCode');

    const magicBtn = document.getElementById('magicBtn');

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
