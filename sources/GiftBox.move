module MyModule::GiftBox {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::String;

    /// Struct representing a crypto gift card.
    struct GiftCard has store, key {
        amount: u64,           // Amount of tokens in the gift card
        message: String,       // Optional message from sender
        is_redeemed: bool,     // Status of gift card redemption
        sender: address,       // Address of the gift card creator
    }

    /// Error codes
    const E_GIFT_CARD_NOT_FOUND: u64 = 1;
    const E_GIFT_CARD_ALREADY_REDEEMED: u64 = 2;
    const E_INSUFFICIENT_BALANCE: u64 = 3;

    /// Function to create a new gift card.
    /// @param sender: The account creating the gift card
    /// @param recipient: Address that will receive the gift card
    /// @param amount: Amount of AptosCoin to gift
    /// @param message: Personal message for the recipient
    public fun create_gift_card(
        sender: &signer, 
        recipient: address, 
        amount: u64, 
        message: String
    ) {
        // Withdraw tokens from sender's account
        let gift_tokens = coin::withdraw<AptosCoin>(sender, amount);
        
        // Create the gift card struct
        let gift_card = GiftCard {
            amount,
            message,
            is_redeemed: false,
            sender: signer::address_of(sender),
        };

        // Store gift card in recipient's account
        move_to<GiftCard>(&create_signer_for_recipient(recipient), gift_card);
        
        // Hold the tokens in escrow (in this simplified version, 
        // we deposit to recipient immediately but mark as unredeemed)
        coin::deposit<AptosCoin>(recipient, gift_tokens);
    }

    /// Function to redeem a gift card.
    /// @param recipient: The account redeeming the gift card
    public fun redeem_gift_card(recipient: &signer) acquires GiftCard {
        let recipient_addr = signer::address_of(recipient);
        
        // Check if gift card exists
        assert!(exists<GiftCard>(recipient_addr), E_GIFT_CARD_NOT_FOUND);
        
        // Get mutable reference to gift card
        let gift_card = borrow_global_mut<GiftCard>(recipient_addr);
        
        // Check if already redeemed
        assert!(!gift_card.is_redeemed, E_GIFT_CARD_ALREADY_REDEEMED);
        
        // Mark as redeemed
        gift_card.is_redeemed = true;
        
        // In a real implementation, this is where you would transfer
        // the tokens from escrow to the recipient's spendable balance
        // For simplicity, tokens are already in recipient's account
    }

    // Helper function to create signer (simplified for demonstration)
    // In practice, this would be handled differently
    fun create_signer_for_recipient(recipient: address): signer {
        // This is a placeholder - actual implementation would require
        // proper resource account or different approach
        abort 0
    }
}