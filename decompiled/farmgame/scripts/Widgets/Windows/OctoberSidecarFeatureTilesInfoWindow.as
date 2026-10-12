package Widgets.Windows
{
   import Display.UI;
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OctoberSidecarFeatureTilesInfoWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      public static const TILESINFO_FTUE_SEEN_FLAG:String = FEATURE_NAME + "_tilesinfo_ftue_seen";
      
      public static const NUM_BUYABLE_LAND_TILES:int = 23;
      
      private var m_featureName:String = null;
      
      private var m_cluecount_tf:ZwTextField;
      
      private var m_tilecount_tf:ZwTextField;
      
      private var m_tilesbuy_bt:FarmAnimatedTextButton;
      
      private var m_ftue_mc:MovieClip;
      
      private var m_ftue_button:FarmAnimatedTextButton;
      
      private var m_currentTileCount:int = 0;
      
      public function OctoberSidecarFeatureTilesInfoWindow(featureName:String = "GilroysParade", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(FEATURE_NAME,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setWindowPosition();
         this.m_currentTileCount = this.manager.currentTileUnlockCount;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"Get More Clues!"));
         }
         if(m_window.hasOwnProperty("tutorial1_mc"))
         {
            this.m_ftue_mc = m_window["tutorial1_mc"] as MovieClip;
            this.m_ftue_mc.visible = false;
            if(this.m_ftue_mc.hasOwnProperty("okay1_bt"))
            {
               this.m_ftue_button = new FarmAnimatedTextButton(this.m_ftue_mc["okay1_bt"],"Great!",this.onTutorialButtonClick);
            }
         }
         if(m_window.hasOwnProperty("clue_count_tf"))
         {
            this.m_cluecount_tf = new ZwTextField(m_window["clue_count_tf"],"x" + (this.m_currentTileCount + 1).toString());
            this.m_cluecount_tf.visible = true;
         }
         if(m_window.hasOwnProperty("tile_count_tf"))
         {
            this.m_tilecount_tf = new ZwTextField(m_window["tile_count_tf"],"x" + (this.m_currentTileCount + 1).toString());
            this.m_tilecount_tf.visible = true;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            this.m_tilesbuy_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Buy Land",this.onBuyTilesClick);
            this.m_tilesbuy_bt.visible = true;
            if(this.m_currentTileCount == NUM_BUYABLE_LAND_TILES)
            {
               this.m_tilesbuy_bt.enabled = false;
               this.m_tilesbuy_bt.detachTooltip();
               this.m_tilesbuy_bt.attachTooltip(new FarmTextTooltip("You own all the required lands!"));
            }
         }
         if(!Global.player.getSeenFlag(TILESINFO_FTUE_SEEN_FLAG))
         {
            if(this.m_ftue_mc)
            {
               this.m_ftue_mc.visible = true;
            }
         }
      }
      
      private function onTutorialButtonClick(e:Event = null) : void
      {
         if(Boolean(this.manager.m_mainWindow) && !Global.player.getSeenFlag(TILESINFO_FTUE_SEEN_FLAG))
         {
            this.manager.m_mainWindow.playFirstTimeTutorial(8);
            Global.player.setSeenFlag(TILESINFO_FTUE_SEEN_FLAG);
         }
         this.close();
      }
      
      private function onBuyTilesClick(e:Event = null) : void
      {
         UI.displayMiniMarketDialog(this.manager.m_tilesList,null,"seed",null,true,false,false,true);
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.close();
         }
         this.close();
      }
      
      private function setWindowPosition() : void
      {
         if(m_window)
         {
            m_window.x += 50;
            m_window.y += 40;
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(Boolean(this.manager.m_mainWindow) && !Global.player.getSeenFlag(TILESINFO_FTUE_SEEN_FLAG))
         {
            this.manager.m_mainWindow.playFirstTimeTutorial(8);
            Global.player.setSeenFlag(TILESINFO_FTUE_SEEN_FLAG);
         }
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.enableInput = true;
            this.manager.m_mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

