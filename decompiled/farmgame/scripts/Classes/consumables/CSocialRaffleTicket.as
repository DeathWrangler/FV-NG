package Classes.consumables
{
   import Classes.Consumable;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.SocialRaffleManager;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CSocialRaffleTicket extends Consumable
   {
      
      protected static const DEFAULT_DELAY_TIME:Number = 2000;
      
      private var m_timer:Timer = null;
      
      public function CSocialRaffleTicket(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var carnivalBooths:Array = null;
         var item2:FarmItem = null;
         var message2:GenericIconPopup = null;
         var result:Boolean = false;
         var featureBuildings:Array = Global.world.getObjectsByName("socialrafflebuilding");
         var featureBuilding:FeatureBuilding = null;
         if(featureBuildings.length > 0)
         {
            featureBuilding = featureBuildings[0] as FeatureBuilding;
         }
         var carnivalBooth:FeatureBuilding = null;
         if(featureBuilding == null)
         {
            carnivalBooths = Global.world.getObjectsByName("carnivalbooth");
            if(carnivalBooths.length > 0)
            {
               carnivalBooth = carnivalBooths[0] as FeatureBuilding;
            }
         }
         if(featureBuilding != null || carnivalBooth != null)
         {
            UI.closeGifts();
            this.m_timer = new Timer(DEFAULT_DELAY_TIME);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
            result = true;
         }
         else
         {
            item2 = Global.farmGameSettingsManager.getFarmItemByName("socialraffleticket");
            message2 = new GenericIconPopup(ZLocUtils.t("Dialogs","socialraffleticket_use_fail"),GenericPopup.TYPE_OK,null,item2.icon,false,true,"",true,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,true);
            UI.displayPopup(message2,false);
         }
         return result;
      }
      
      override public function onUse() : void
      {
         SocialRaffleManager.getInstance().updateNumGivenTickets(1);
         SocialRaffleManager.getInstance().applyRaffleTicketEffect(1);
      }
      
      protected function onTimer(event:TimerEvent) : void
      {
         UI.displayGiftBoxWindow();
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
   }
}

