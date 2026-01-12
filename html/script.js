const sendContainer = document.getElementById('send-container');
const receiveContainer = document.getElementById('receive-container');
const targetIdInput = document.getElementById('target-id');
const messageInput = document.getElementById('message');
const charCurrent = document.getElementById('char-current');
const charMax = document.getElementById('char-max');
const senderNameSpan = document.getElementById('sender-name');
const messageContent = document.getElementById('message-content');
const replyBtn = document.getElementById('btn-reply');

let maxLength = 140;
let canReply = false;

// Listen for messages from the client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'open':
            maxLength = data.maxLength || 140;
            charMax.textContent = maxLength;
            messageInput.maxLength = maxLength;
            openSendUI();
            break;
        
        case 'openReply':
            maxLength = data.maxLength || 140;
            charMax.textContent = maxLength;
            messageInput.maxLength = maxLength;
            openSendUI(data.targetId);
            break;
            
        case 'close':
            closeAllUI();
            break;
            
        case 'showMessage':
            canReply = data.canReply || false;
            showReceivedMessage(data.senderName, data.message);
            break;
    }
});

function openSendUI(prefillTargetId) {
    closeAllUI();
    sendContainer.classList.remove('hidden');
    targetIdInput.value = prefillTargetId || '';
    messageInput.value = '';
    charCurrent.textContent = '0';
    
    // If target is pre-filled (reply), focus on message. Otherwise focus on target ID.
    if (prefillTargetId) {
        targetIdInput.readOnly = true;
        targetIdInput.classList.add('readonly');
        messageInput.focus();
    } else {
        targetIdInput.readOnly = false;
        targetIdInput.classList.remove('readonly');
        targetIdInput.focus();
    }
}

function closeAllUI() {
    sendContainer.classList.add('hidden');
    receiveContainer.classList.add('hidden');
}

function showReceivedMessage(sender, message) {
    closeAllUI();
    senderNameSpan.textContent = sender;
    messageContent.textContent = message;
    
    // Show/hide reply button based on whether we can reply
    if (canReply) {
        replyBtn.classList.remove('hidden');
    } else {
        replyBtn.classList.add('hidden');
    }
    
    receiveContainer.classList.remove('hidden');
}

// Character counter
messageInput.addEventListener('input', function() {
    charCurrent.textContent = this.value.length;
});

// Send button
document.getElementById('btn-send').addEventListener('click', function() {
    const targetId = targetIdInput.value.trim();
    const message = messageInput.value.trim();
    
    if (!targetId || !message) {
        return;
    }
    
    fetch('https://carrier_pigeon/sendMessage', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            targetId: parseInt(targetId),
            message: message
        })
    });
});

// Cancel button
document.getElementById('btn-cancel').addEventListener('click', function() {
    fetch('https://carrier_pigeon/closeUI', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Close button (received message)
document.getElementById('btn-close').addEventListener('click', function() {
    fetch('https://carrier_pigeon/closeMessage', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Reply button
document.getElementById('btn-reply').addEventListener('click', function() {
    fetch('https://carrier_pigeon/replyMessage', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Handle ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch('https://carrier_pigeon/closeUI', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

// Handle Enter key in target ID field (move to message)
targetIdInput.addEventListener('keydown', function(event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        messageInput.focus();
    }
});