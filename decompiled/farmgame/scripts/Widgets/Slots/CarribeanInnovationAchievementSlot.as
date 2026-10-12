package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.CarribeanInnovationAchievementWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CarribeanInnovationAchievementSlot extends ZwSlotFrame
   {
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const EXPIRED_MC:String = "expired_mc";
      
      private var m_data:Object;
      
      protected var m_item:FarmItem = null;
      
      protected var m_itemName:String = null;
      
      private var m_featureName:String;
      
      private const REDEEM_BT:String = "redeem_bt";
      
      private var m_slotIndex:Number = 0;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_parentWindow:CarribeanInnovationAchievementWindow;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private var m_checkMark:MovieClip = null;
      
      private const COUNT_TF:String = "count_tf";
      
      private var m_bodyTf:ZwTextField = null;
      
      private var m_expired:MovieClip;
      
      private const ACTIVE_MC:String = "active_mc";
      
      private var m_active:MovieClip;
      
      private var m_titleTf:ZwTextField;
      
      public function CarribeanInnovationAchievementSlot(element:DisplayObject, featureName:String, parentWindow:CarribeanInnovationAchievementWindow)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_parentWindow = parentWindow;
         if(m_element.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_element["title_tf"],"Default Text "));
         }
         if(m_element.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_element["body_tf"],"Default Text "));
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkMark = m_element[this.CHECKMARK_MC] as MovieClip;
            this.m_checkMark.visible = true;
         }
         if(m_element.hasOwnProperty(this.EXPIRED_MC))
         {
            this.m_expired = m_element[this.EXPIRED_MC] as MovieClip;
            this.m_expired.visible = true;
         }
         if(m_element.hasOwnProperty(this.REDEEM_BT))
         {
            this.m_redeemButton = new FarmAnimatedTextButton(m_element[this.REDEEM_BT],"Redeem",this.onRedeemItem);
            this.m_redeemButton.visible = true;
            this.m_redeemButton.enabled = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.m_data = data;
         this.m_slotIndex = this.m_data.rewardSlotNumber;
         this.getAchievementItem();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(this.m_bodyTf)
         {
            this.m_bodyTf.visible = true;
         }
         if(this.m_titleTf)
         {
            this.m_titleTf.visible = true;
         }
         if(Boolean(this.m_redeemButton) && this.isRedeemActive())
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.visible = true;
         }
         else
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.visible = false;
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = this.isAchievementRedeemed();
         }
         if(this.m_expired)
         {
            this.m_expired.visible = this.isAchievementExpired();
         }
      }
      
      private function getAchievementItem() : void
      {
         switch(this.m_slotIndex)
         {
            case 0:
               this.m_itemName = "foodiesfavouritecertificate";
               this.m_titleTf.text = "Foodie’s Favourite Certificate";
               if(!this.isAchievementRedeemed())
               {
                  this.m_bodyTf.text = "Reach 250 Fame by 6 May";
               }
               else
               {
                  this.m_bodyTf.text = "You reached 250 Fame by 6 May";
               }
               break;
            case 1:
               this.m_itemName = "heavenlyfoodaward";
               this.m_titleTf.text = "Heavenly Food Award";
               if(!this.isAchievementRedeemed())
               {
                  this.m_bodyTf.text = "Reach 500 Fame by 13 May";
               }
               else
               {
                  this.m_bodyTf.text = "You reached 500 Fame by 13 May";
               }
               break;
            case 2:
               this.m_itemName = "foodacademyaward";
               this.m_titleTf.text = "Food Academy Award";
               if(!this.isAchievementRedeemed())
               {
                  this.m_bodyTf.text = "Reach 750 Fame by 20 May";
               }
               else
               {
                  this.m_bodyTf.text = "You reached 750 Fame by 20 May";
               }
               break;
            case 3:
               this.m_itemName = "gourmetkingtrophy";
               this.m_titleTf.text = "Gourmet King Trophy";
               if(!this.isAchievementRedeemed())
               {
                  this.m_bodyTf.text = "Reach 950 Fame by 27 May";
               }
               else
               {
                  this.m_bodyTf.text = "You reached 950 Fame by 27 May";
               }
         }
      }
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(this.m_featureName);
      }
      
      private function isRedeemActive() : Boolean
      {
         var result:Boolean = false;
         return this.manager.isAchievementRedeemActive(this.m_slotIndex);
      }
      
      private function isAchievementExpired() : Boolean
      {
         var result:Boolean = false;
         return this.manager.isAchievementExpired(this.m_slotIndex);
      }
      
      private function isAchievementRedeemed() : Boolean
      {
         var result:Boolean = false;
         return this.manager.isAchievementRedeemed(this.m_slotIndex);
      }
      
      private function getBodyText() : String
      {
         return "default";
      }
      
      private function onRedeemItem(event:Event) : void
      {
         this.m_redeemButton.visible = false;
         this.manager.redeemAchievement(this.m_slotIndex);
      }
   }
}

