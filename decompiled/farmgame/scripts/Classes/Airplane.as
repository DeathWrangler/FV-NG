package Classes
{
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.IntVector2;
   import Events.GenericPopupEvent;
   import GameMode.GMAirplaneFly;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class Airplane extends Equipment
   {
      
      private static const APPLY_GROW:String = "applyInstantGrow";
      
      public static const FIRST_AIRPLANE_FLY_FLAG:String = "firstAirplaneFly";
      
      public static const REAR_FLY:String = "rearfly";
      
      public static const FRONT_FLY:String = "frontfly";
      
      public static const SERVICE_NAME:String = "instagrow";
      
      private var m_currentFlyingDirection:String;
      
      private var m_isFlying:Boolean;
      
      public function Airplane(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
         this.m_currentFlyingDirection = FRONT_FLY;
      }
      
      public function get currentFlyingDirection() : String
      {
         return this.m_currentFlyingDirection;
      }
      
      public function get isFlying() : Boolean
      {
         return this.m_isFlying;
      }
      
      public function setflying(isFlying:Boolean, direction:String = "frontfly") : void
      {
         this.m_isFlying = isFlying;
         if(this.m_isFlying == true)
         {
            this.m_currentFlyingDirection = direction;
         }
         m_image = null;
         conditionallyRedraw(true);
      }
      
      override protected function setActionSize() : void
      {
         m_actionSize = new IntVector2(0,0);
      }
      
      override protected function getMenuItems() : Array
      {
         return [{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
            "action":APPLY_GROW
         }];
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var result:ItemImage = null;
         var imageName:String = "";
         if(this.m_isFlying)
         {
            imageName = this.m_currentFlyingDirection;
         }
         else
         {
            imageName = "frontstatic";
         }
         imageName = postProcessImageName(imageName);
         if(m_item)
         {
            result = m_item.getCachedImage(imageName);
         }
         return result;
      }
      
      public function hasLoadedImageForFlying() : Boolean
      {
         return m_item.getCachedImage(FRONT_FLY) != null;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var clickedApplyGrow:Boolean = false;
         var message:String = null;
         var dialog:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            clickedApplyGrow = false;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case STORE_OBJECT:
                  onAddToInventory();
                  break;
               case APPLY_GROW:
                  m_active = true;
                  clickedApplyGrow = true;
                  FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","biplane","instant_grow","","User opens context menu from biplane, clicks on instant_grow");
                  if(Global.world.addGameMode(new GMAirplaneFly(this),true) == false)
                  {
                     message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                     dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                     UI.displayPopup(dialog);
                  }
                  break;
               default:
                  super.onMenuClick(event);
            }
            if(!clickedApplyGrow)
            {
               FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","biplane","all_other_options","","User opens context menu from biplane, clicks on all_other_options");
            }
         }
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         if(Boolean(transactionResult.creditsAwarded) && transactionResult.creditsAwarded > 0)
         {
            Global.player.addFarmServiceCredit(Airplane.SERVICE_NAME,transactionResult.creditsAwarded);
         }
         var dialog:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","InstantGrow_AirplanePurchase"),GenericPopup.TYPE_SHARECANCEL,this.onSharePlaneClose);
         UI.displayPopup(dialog,true,"AirplanePlaceShare",true);
      }
      
      private function onSharePlaneClose(event:GenericPopupEvent) : void
      {
         var actionBundle:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               actionBundle = m_item.getStringFromDataSource("actionBundle");
            }
            else
            {
               actionBundle = m_item.xml.@actionBundle.toString();
            }
            if(actionBundle != null && actionBundle != "")
            {
               params = {
                  "actor":Global.player.name,
                  "images":[{
                     "src":m_item.icon,
                     "href":Config.SN_APP_URL
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(actionBundle,params,[],false);
            }
         }
         Global.world.addGameMode(new GMAirplaneFly(this),true);
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return !this.isFlying;
      }
   }
}

