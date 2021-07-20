import { iconClasses } from '@material-ui/core'
import React from 'react'
import './Header.css'
import LuggageIcon from '@material-ui/icons/Luggage';
import NotificationsIcon from '@material-ui/icons/Notifications';
import LanguageIcon from '@material-ui/icons/Language';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import { Avatar } from '@material-ui/core';

function Header() {
    return (
        <div className='header'>
            <img className="header__icon"
            src="https://uploads-ssl.webflow.com/5ac286bb60db4938a648e594/5acd1a998bad9920b5c7c738_Global%20Aviation%20Logo.png"/>
        
            <div className='header_title'>
                <h1>Safe Flight</h1>
            </div>

            <div className='header_quote'>
            <div id="div1">Powered by </div>
            <div id="div2"> AstraDB</div>
            </div>

            <div className='header_right'>
                <LuggageIcon />
                <p> Find my baggage </p>
                <NotificationsIcon />
                <p> Alerts </p>
                <LanguageIcon />
                <ExpandMoreIcon />
                <Avatar />
            </div>


        </div>
    )
}

export default Header
