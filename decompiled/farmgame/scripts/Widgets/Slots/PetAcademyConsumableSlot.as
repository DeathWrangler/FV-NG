package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.PetAcademyManager;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.PetAcademyExamWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PetAcademyConsumableSlot extends ZwSlotFrame
   {
      
      protected var m_owner:PetAcademyExamWindow;
      
      private var m_data:Object;
      
      private var m_featureName:String;
      
      private var m_itemName:ZwTextField;
      
      private var m_selectBt:FarmAnimatedTextButton;
      
      private var m_comsumableIcon:FarmIcon;
      
      private var m_completeIcon_mc:MovieClip;
      
      private var m_slotIndex:int;
      
      private var m_animalName:String;
      
      private var m_professionName:String;
      
      private var m_consumableBuyBt:FarmAnimatedTextButton;
      
      private var m_consumableCraft:FarmAnimatedTextButton;
      
      private var m_consumableAskBt:FarmAnimatedTextButton;
      
      private var m_consumableCount:ZwTextField;
      
      private var m_consumableSinkBt:FarmAnimatedTextButton;
      
      private var m_consumableCode:String;
      
      public function PetAcademyConsumableSlot(element:DisplayObject, owner:PetAcademyExamWindow)
      {
         super(element);
         this.m_owner = owner;
         m_element.visible = true;
         this.m_featureName = WanderingPirateManager.FEATURE_NAME;
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_comsumableIcon = new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_consumableBuyBt = new FarmAnimatedTextButton(m_element["buy_bt"],"Buy",this.onBuyClick),true);
         }
         if(m_element.hasOwnProperty("craftpotion_bt"))
         {
            addWidget(this.m_consumableCraft = new FarmAnimatedTextButton(m_element["craftpotion_bt"],"Craft",this.onCraftClick),true);
         }
         if(m_element.hasOwnProperty("post_mc"))
         {
            addWidget(this.m_consumableAskBt = new FarmAnimatedTextButton(m_element["post_mc"],"Ask",this.onAskClick),true);
         }
         if(m_element.hasOwnProperty("redeem_bt"))
         {
            addWidget(this.m_consumableSinkBt = new FarmAnimatedTextButton(m_element["redeem_bt"],"Redeem",this.onRedeemClick),true);
         }
         if(m_element.hasOwnProperty("rewardcount_tf"))
         {
            addWidget(this.m_consumableCount = new ZwTextField(m_element.rewardcount_tf,"X0"));
         }
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_completeIcon_mc = m_element.completeIcon_mc as MovieClip;
            this.m_completeIcon_mc.visible = false;
         }
      }
      
      public function onBuyClick(e:Event) : void
      {
         this.m_owner.tintWindow();
         this.m_owner.enableInput = false;
         PetAcademyManager.getInstance().buyConsumable(this.m_slotIndex,this.m_owner);
      }
      
      public function onCraftClick(e:Event) : void
      {
         PetAcademyManager.getInstance().craftConsumable(this.m_slotIndex);
      }
      
      public function onAskClick(e:Event) : void
      {
         PetAcademyManager.getInstance().askConsumable(this.m_slotIndex);
         this.refreshAskBtn();
      }
      
      private function getCorrectFeedID() : String
      {
         var feed_ID:String = null;
         switch(this.m_slotIndex)
         {
            case 0:
               feed_ID = PetAcademyManager.FEED1_NAME;
               break;
            case 1:
               feed_ID = PetAcademyManager.FEED2_NAME;
               break;
            case 2:
               feed_ID = PetAcademyManager.FEED3_NAME;
         }
         return feed_ID;
      }
      
      private function refreshAskBtn() : void
      {
         var feedID:String = null;
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_consumableAskBt)
         {
            feedID = this.getCorrectFeedID();
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(feedID);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableAskBt,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_consumableAskBt.enabled = true;
               this.m_consumableAskBt.detachTooltip();
            }
         }
      }
      
      public function onRedeemClick(e:Event) : void
      {
         PetAcademyManager.getInstance().sinkConsumable(this.m_slotIndex);
      }
      
      override public function populate(data:Object) : void
      {
         var x:FarmTextTooltip = null;
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.slotIndex;
         this.m_consumableCode = this.m_data.consumableCode;
         this.m_comsumableIcon.visible = true;
         this.m_consumableSinkBt.visible = true;
         this.m_comsumableIcon.loadIcon(this.manager.consumableFarmItem(this.m_slotIndex).getImageByName("icon"));
         this.m_comsumableIcon.detachTooltip();
         this.m_comsumableIcon.attachTooltip(x = new FarmTextTooltip(this.manager.consumableFarmItem(this.m_slotIndex).friendlyTitle));
         this.m_consumableCount.text = this.manager.consumableCount(this.m_slotIndex).toString() + "/" + this.manager.getConsumableRequiredForAnimalExamLevel(this.manager.activeAnimal,this.manager.activeProfession,this.manager.activeExamLevel)[this.m_slotIndex].toString();
         if(this.manager.activeExamSetProgress(this.m_slotIndex) == 1)
         {
            this.m_completeIcon_mc.visible = true;
            this.m_consumableBuyBt.visible = false;
            this.m_consumableCraft.visible = false;
            this.m_consumableAskBt.visible = false;
            this.m_consumableCount.visible = false;
            this.m_consumableSinkBt.callback = null;
            this.m_consumableSinkBt.enabled = false;
            this.m_consumableSinkBt.visible = false;
         }
         else
         {
            this.m_completeIcon_mc.visible = false;
            this.m_consumableBuyBt.visible = true;
            this.m_consumableCraft.visible = true;
            this.m_consumableAskBt.visible = true;
            this.m_consumableCount.visible = true;
            this.m_consumableSinkBt.text = "Redeem";
            this.refreshAskBtn();
            if(this.manager.consumableCount(this.m_slotIndex) >= this.m_data.required)
            {
               this.m_consumableSinkBt.enabled = true;
               this.m_consumableSinkBt.detachTooltip();
               this.m_consumableSinkBt.callback = this.onRedeemClick;
               this.m_consumableBuyBt.visible = false;
               this.m_consumableCraft.visible = false;
               this.m_consumableAskBt.visible = false;
            }
            else
            {
               this.m_consumableSinkBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_consumableSinkBt,"Not Enough " + this.manager.consumableFarmItem(this.m_slotIndex).friendlyTitle);
            }
         }
      }
      
      override public function release() : void
      {
         this.m_comsumableIcon = null;
         this.m_selectBt = null;
         this.m_completeIcon_mc = null;
         super.release();
      }
      
      private function get manager() : PetAcademyManager
      {
         return PetAcademyManager.getInstance();
      }
   }
}

