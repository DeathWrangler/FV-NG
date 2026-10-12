package Transactions
{
   import Classes.TargetedConsumable;
   import Classes.consumables.*;
   import Display.UI;
   
   public class TUseTargetedConsumable extends TWorldState
   {
      
      private var m_params:Object;
      
      private var m_itemName:String;
      
      private var m_targetedConsumable:TargetedConsumable;
      
      private var m_showGiftDialog:Boolean;
      
      public function TUseTargetedConsumable(itemName:String, targetObjectId:Number, isGift:Boolean = true, userID:String = "", isFree:Boolean = false, showGiftDialog:Boolean = false)
      {
         var uid:String = null;
         this.m_itemName = itemName;
         this.m_showGiftDialog = showGiftDialog;
         this.m_params = new Object();
         this.m_params.isGift = isGift;
         this.m_params.isFree = isFree;
         this.m_params.targetObjectId = String(targetObjectId);
         if(userID == "")
         {
            uid = Global.player.uid;
            if(isNaN(Number(uid)))
            {
               uid = "0";
            }
            userID = uid;
         }
         this.m_params.targetUser = String(userID);
         this.m_targetedConsumable = TargetedConsumable.createTargetedConsumable(this.m_itemName,targetObjectId);
         super(this.m_targetedConsumable);
         if(this.m_targetedConsumable.canUse())
         {
            if(this.m_params.isGift)
            {
               Global.player.removeGift(null,this.m_itemName);
            }
            if(this.m_showGiftDialog)
            {
               UI.displayGiftBoxWindow();
            }
         }
         else
         {
            canPerform = false;
            this.m_targetedConsumable.onFailedPerform();
         }
      }
      
      override public function perform() : void
      {
         signedWorldAction(TWorldState.ACTION_USE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_targetedConsumable)
         {
            this.m_targetedConsumable.onUse();
         }
      }
      
      public function targetObjectId() : Number
      {
         return this.m_params.targetObjectId;
      }
   }
}

