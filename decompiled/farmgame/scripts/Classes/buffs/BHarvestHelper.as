package Classes.buffs
{
   import Classes.Buff;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.ToasterManager;
   import Widgets.Windows.Toasters.HarvestHelperToasterWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BHarvestHelper extends Buff
   {
      
      public static const CLASS_NAME:String = "BHarvestHelper";
      
      public static const BUFF_ITEM_NAME:String = "buff_harvest_helper";
      
      public static const MULTIPLIER_VALUE:int = 50;
      
      private var m_timer:Timer;
      
      public function BHarvestHelper(itemName:String)
      {
         super(itemName);
      }
      
      public static function getHarvestHelperMultiplier() : Number
      {
         var isHHActive:Boolean = isHarvestHelperActive();
         return isHHActive ? MULTIPLIER_VALUE / 100 : 1;
      }
      
      private static function isHarvestHelperActive() : Boolean
      {
         var harvestHelperBuffs:Array = null;
         var buff:BHarvestHelper = null;
         var result:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty("HARVEST_HELPER_ENABLED") && Boolean(Global.flashHotParams["HARVEST_HELPER_ENABLED"]))
         {
            result = true;
         }
         else
         {
            harvestHelperBuffs = Global.player.getBuffsByClass(BHarvestHelper);
            if(harvestHelperBuffs.length > 0)
            {
               buff = new BHarvestHelper(BUFF_ITEM_NAME);
               if(!buff.isExpired())
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      override public function apply(isNew:Boolean = false) : void
      {
         var startHour:int = 0;
         var toaster:HarvestHelperToasterWindow = null;
         if(!Global.player.buffs[m_itemName] && isNew)
         {
            startHour = GlobalEngine.serverTime / 1000;
            Global.player.buffs[m_itemName] = {"time":startHour};
         }
         var hasExpired:Boolean = isExpired();
         if(isNew && !hasExpired)
         {
            toaster = new HarvestHelperToasterWindow(this.onToasterCloseCallback);
            ToasterManager.getInstance().add(toaster);
         }
         else if(!hasExpired)
         {
            Global.hud.toggleHarvestHelperHudIconVisibility(true);
            this.onTimer(null);
         }
      }
      
      override public function unapply() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         Global.hud.toggleHarvestHelperHudIconVisibility(false);
         super.unapply();
      }
      
      private function onToasterCloseCallback(animationStartX:Number, animationStartY:Number) : void
      {
         Global.hud.toggleHarvestHelperHudIconVisibility(true,true,animationStartX,animationStartY);
      }
      
      private function getDisplayText() : String
      {
         var result:String = "";
         var expiryTime:Number = getExpiresTTL();
         var startTime:Number = getAddedTime();
         var timeRemaining:Number = startTime + expiryTime - GlobalEngine.serverTime / 1000;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(numDays > 1)
         {
            result = ZLocUtils.t("Dialogs","Harvest_Helper_Hud_text",{"days":numDays});
         }
         else
         {
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer.start();
            }
            result = HUD.getformattedTimeLeft(timeRemaining);
         }
         if(timeRemaining <= 0)
         {
            Global.hud.toggleHarvestHelperHudIconVisibility(false);
         }
         return result;
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var text:String = this.getDisplayText();
         Global.hud.updateHarvestHelperTime(text);
      }
   }
}

