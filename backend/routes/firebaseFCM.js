const { response } = require("express");
const express = require("express");
const router = express.Router();
const bodyParser = require('body-parser');

const axios = require('axios');

router.use(bodyParser.json());





router.post('/requestHandyman', async (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Authorization', 'key=AIzaSyDrT_0nzeqNQ1cxIWwA3Acet5yOLrivu2k');

    try {
        const data = req.body;
        if (!data) {
            return res.status(400).json({ message: 'Invalid parameter' });
        }
        const param = {
            'priority': 'high',
            'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': 'MyHandyman',
                'title': 'Halo ' + data.email + ' kamu berhasil mendapatkan Handyman !',
            },
            'notification': {
                'body': 'MyHandyman',
                'title': 'Halo ' + data.email + ' kamu berhasil mendapatkan Handyman !',
                'android_channel_id': "dbFood"
            },
            "to": data.token
        }
        return res.status(200).json(param);
    } catch (error) {
        return res.status(500).json({ message: ex.message });
    }
})

module.exports = router;