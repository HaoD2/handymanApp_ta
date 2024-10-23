
const { response } = require("express");
const express = require("express");
const router = express.Router();
const bodyParser = require('body-parser');
const axios = require('axios');
const midtransClient = require('midtrans-client');

const basicAuth = require('express-basic-auth')

// Middleware untuk parsing body JSON
router.use(bodyParser.json());

// Middleware untuk Basic Authentication
const users = {
    'SB-Mid-server-jHCvz3LmqB9xqdY7KYD5Tu9d': '' // Gantilah dengan username dan password yang sesuai
};

router.use(basicAuth({
    users,
    challenge: true,
    unauthorizedResponse: 'Unauthorized'
}));

// Set Your server key
const SERVER_KEY = 'SB-Mid-server-jHCvz3LmqB9xqdY7KYD5Tu9d';
const CLIENT_KEY = 'SB-Mid-client-jhD9pidqs-k7Zier';

router.post('/purchase', async (req, res) => {
    // Set header Accept dan Content-Type
    res.setHeader('Accept', 'application/json');
    res.setHeader('Content-Type', 'application/json');

    try {
        const data = req.body;

        if (!data) {
            return res.status(400).json({ message: 'Invalid parameter' });
        }
        // Create Snap API instance
        const snap = new midtransClient.Snap({
            isProduction: false,
            serverKey: SERVER_KEY,
            clientKey: CLIENT_KEY
        });
        const param = {
            item_details: {
                id: data.item_details.id,
                name: data.item_details.tipe_pekerjaan,
                price: data.item_details.price,
                quantity: 1
            },
            transaction_details: {
                order_id: data.transaction_detail.order_id,
                gross_amount: data.transaction_detail.gross_amount,
            },
            customer_details: {
                email: data.customer_detail.user,
            }

        };

        const transaction = await snap.createTransaction(param);
        const transaction_token = transaction.token;
        const transaction_redirect = transaction.redirect_url;


        return res.status(200).json(
            {
                "token": transaction_token,
                "redirect": transaction_redirect
            });
    } catch (ex) {
        return res.status(500).json({ message: ex.message });

    }
});

const fetch = require('node-fetch');

router.post('/cancelPurchase', async (req, res) => {
    res.setHeader('accept', 'application/json');
    try {
        const data = req.body;
        if (!data || !data.order_id) {
            return res.status(400).json({ message: 'Invalid parameter' });
        }

        // URL untuk melakukan pembatalan transaksi di Midtrans
        const url = `https://api.sandbox.midtrans.com/v2/${data.order_id}/cancel`;

        // Opsi request dengan serverKey Midtrans (autentikasi Basic)
        const options = {
            method: 'POST',
            headers: {
                accept: 'application/json',
                'Content-Type': 'application/json',
                Authorization: `Basic ${Buffer.from(SERVER_KEY).toString('base64')}`
            }
        };

        // Kirim request ke API Midtrans
        const response = await fetch(url, options);
        const jsonResponse = await response.json();

        // Kirimkan response dari Midtrans ke client
        if (response.ok) {
            return res.status(200).json(jsonResponse);
        } else {
            return res.status(response.status).json(jsonResponse);
        }

    } catch (ex) {
        return res.status(500).json({ message: ex.message });
    }
});

module.exports = router;