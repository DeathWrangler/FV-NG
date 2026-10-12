package Classes.Idle
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.USDPaidGifting.USDPaidGiftingConstants;
   import Classes.USDPaidGifting.USDPaidGiftingManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Managers.LESurfacingManager;
   import Transactions.TBuyAndSendPresent;
   import Widgets.Windows.MFSSendPaidGift;
   import Widgets.Windows.MFSSendUSDPaidGift;
   
   public class PaidGiftingIdleTask extends BaseIdleTask
   {
      
      private static const DEFAULT_CHANCE_TO_ADD:Number = 0.25;
      
      private static const FEATURE_FLASHPARAM_PAID_GIFTING_ON_IDLE_CHANCE_TO_SHOW:String = "PAID_GIFTING_ON_IDLE_CHANCE_TO_SHOW";
      
      public function PaidGiftingIdleTask(params:Object = null)
      {
         super();
         m_displaysPopup = true;
      }
      
      private static function getSendableLEItems(LEItems:Array) : Array
      {
         var numLEItems:int = 0;
         var i:int = 0;
         var LEItem:FarmItem = null;
         var sendableLEItems:Array = new Array();
         if(LEItems != null)
         {
            numLEItems = int(LEItems.length);
            for(i = 0; i < numLEItems; i++)
            {
               LEItem = LEItems[i];
               if(LEItem != null && LEItem.isPresent)
               {
                  sendableLEItems.push(LEItem);
               }
            }
         }
         return sendableLEItems;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         var chanceToAdd:Number = Number(Global.flashHotParams[FEATURE_FLASHPARAM_PAID_GIFTING_ON_IDLE_CHANCE_TO_SHOW]);
         if(isNaN(chanceToAdd) || chanceToAdd < 0 || chanceToAdd > 1)
         {
            chanceToAdd = DEFAULT_CHANCE_TO_ADD;
         }
         return Math.random() <= chanceToAdd && !Global.player.getSeenSessionFlag(FEATURE_FLASHPARAM_PAID_GIFTING_ON_IDLE_CHANCE_TO_SHOW) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PAID_GIFTING_ON_IDLE_V2) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
      
      override public function get minActionIdleMilliseconds() : Number
      {
         return W2EIdleTask.ACTION_QUEUE_EMPTY_MILLISECONDS + FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return W2EIdleTask.MOUSE_IDLE_MILLISECONDS + FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      override public function get canFire() : Boolean
      {
         return LESurfacingManager.instance.hasBeenShown() && (!W2EIdleTask.shouldAddStatic() || !W2EIdleTask.canFireStatic());
      }
      
      override public function fire() : void
      {
         var LEItems:Array = null;
         var sendableLEItems:Array = null;
         var numLEItemsLeft:int = 0;
         var randomLEItem:FarmItem = null;
         var wasWindowOpened:Boolean = false;
         var usdPaidGiftingManager:USDPaidGiftingManager = new USDPaidGiftingManager(USDPaidGiftingConstants.IDLE_FEATURE_NAME,"idle");
         if(usdPaidGiftingManager.isFeatureEnabled())
         {
            UI.displayPopup(new MFSSendUSDPaidGift(usdPaidGiftingManager,TBuyAndSendPresent.ITEMCONTEXT_PAID_GIFTING_ON_IDLE,null,StatsTrackingConstants.PAID_GIFTING_ON_IDLE));
            wasWindowOpened = true;
         }
         else
         {
            LEItems = LESurfacingManager.instance.getLeSet();
            sendableLEItems = getSendableLEItems(LEItems);
            numLEItemsLeft = int(sendableLEItems.length);
            if(numLEItemsLeft > 0)
            {
               randomLEItem = sendableLEItems[FarmGameUtil.getRandomInt(numLEItemsLeft - 1)];
               if(randomLEItem != null)
               {
                  UI.displayPopup(new MFSSendPaidGift(randomLEItem,TBuyAndSendPresent.ITEMCONTEXT_PAID_GIFTING_ON_IDLE,null,StatsTrackingConstants.PAID_GIFTING_ON_IDLE));
                  wasWindowOpened = true;
               }
            }
         }
         if(wasWindowOpened)
         {
            Global.player.setSeenSessionFlag(FEATURE_FLASHPARAM_PAID_GIFTING_ON_IDLE_CHANCE_TO_SHOW);
         }
      }
   }
}

