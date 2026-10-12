package Display.HUD.HUDWidgets
{
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.util.FarmGameUtil;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetMOTD;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudLandBundle extends HUDWidget
   {
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const STATE_IDLE_MC:String = "hud_notif_0_mc";
      
      private static const X_OFFSET:int = 100;
      
      private static const Y_OFFSET:int = 130;
      
      private static var MOTD_DATA:Object = null;
      
      private static var SENT_RQST_FOR_MOTD:Boolean = false;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_motdName:String;
      
      public function HudLandBundle()
      {
         super("assets/dialogs/whitewinter/landbundle/FV_xfw_hud_LandBundle.swf",Global.hud);
         this.m_featureName = "LandBundleWhiteWinter";
         this.m_motdName = "MOTD_LAND_BUNDLE_WHITEWINTER";
      }
      
      private static function setMotdData(motdData:Object) : void
      {
         MOTD_DATA = motdData;
      }
      
      private static function getMotdData() : Object
      {
         return MOTD_DATA;
      }
      
      private static function setSentRqstForMotd(sentRqstForMotd:Boolean) : void
      {
         SENT_RQST_FOR_MOTD = sentRqstForMotd;
      }
      
      private static function getSentRqstForMotd() : Boolean
      {
         return SENT_RQST_FOR_MOTD;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var parentFrame:ZwFrame = null;
         var n1:Number = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber("12/18/2017")) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var n2:Number = (GlobalEngine.serverTime - FarmGameUtil.synchronizedDateToNumber("12/28/2017")) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(n1 > 0 && n2 < 0)
         {
            super.onLoadComplete(event);
            m_element.filters = [new DropShadowFilter()];
            this.setXY();
            parentFrame = new ZwFrame(m_element);
            (parentFrame.element as MovieClip).stop();
            if(m_element.hasOwnProperty(HUD_MC))
            {
               addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.showMOTD),true);
               this.m_hudButton.attachTooltip(new FarmTextTooltip("Great Winter Plain"));
               if(m_element[HUD_MC].hasOwnProperty(STATE_IDLE_MC))
               {
                  (m_element[HUD_MC][STATE_IDLE_MC] as MovieClip).visible = true;
               }
            }
         }
      }
      
      private function test(e:Event = null) : void
      {
      }
      
      private function showMOTD(event:Event = null) : void
      {
         if(MultiRewardTreasurePayerLandBundleConstructionBuilding.isBundleAvailable())
         {
            if(getSentRqstForMotd())
            {
               MOTD.displayMOTD(getMotdData());
            }
            else
            {
               TransactionManager.addTransaction(new TGetMOTD(this.m_motdName,this.onGetMOTD),true);
            }
         }
         else
         {
            this.release();
         }
      }
      
      private function onGetMOTD(motdData:Object) : void
      {
         if(Boolean(motdData) && motdData.hasOwnProperty("motdSeenFlag"))
         {
            setSentRqstForMotd(true);
            setMotdData(motdData);
            MOTD.displayMOTD(motdData,false);
         }
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
      
      override public function release() : void
      {
         this.m_hudButton = null;
         super.release();
      }
   }
}

