package Display.HUD
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Events.FarmGameWorldEvent;
   import Managers.FarmStatsManager;
   import Managers.IrrigationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GetMoreWaterWindow;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class WaterHudButton extends ZwAbstractWindow
   {
      
      private static const X_POSITION:Number = 410;
      
      private static const Y_POSITION:Number = 5;
      
      private var m_amountText:ZwTextField;
      
      private var m_buyButton:FarmAnimatedButton;
      
      private const ASSET_PATH:String = "assets/hud/water_HUD_Meter.swf";
      
      public function WaterHudButton()
      {
         super(Global.getAssetURL(this.ASSET_PATH));
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.x = X_POSITION;
         this.y = Y_POSITION;
         if("water_tf" in m_window)
         {
            this.m_amountText = new ZwTextField(m_window.water_tf,"0");
            addWidget(this.m_amountText);
         }
         if("buy_bt" in m_window)
         {
            this.m_buyButton = new FarmAnimatedButton(m_window.buy_bt,this.handleWaterButtonClicked);
            addWidget(this.m_buyButton);
         }
         if(Global.player.postInitFinished)
         {
            this.determineVisibility();
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.determineVisibility);
         }
         m_window.addEventListener(MouseEvent.MOUSE_DOWN,this.handleWaterButtonClicked);
      }
      
      override protected function release() : void
      {
         m_window.removeEventListener(MouseEvent.MOUSE_DOWN,this.handleWaterButtonClicked);
         super.release();
      }
      
      private function determineVisibility(e:Event = null) : void
      {
         var max:int = 0;
         var amt:int = 0;
         var visibility:Boolean = false;
         if(IrrigationManager.instance.isInExperiment() && Global.player.postInitFinished)
         {
            visibility = Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME;
            if(visibility && Boolean(this.m_amountText))
            {
               max = IrrigationManager.instance.getMaxWaterForActionType(IrrigationManager.WATER_PLOTS);
               amt = IrrigationManager.instance.getWaterAmount(IrrigationManager.WATER_PLOTS);
               this.m_amountText.text = "" + amt;
               if(!this.m_amountText.tooltip)
               {
                  this.m_amountText.attachTooltip(new FarmTextTooltip());
               }
               (this.m_amountText.tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","Irrigation_hud_tooltip",{
                  "count":amt,
                  "max":max
               }));
            }
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.determineVisibility);
         }
         this.visible = visibility;
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      public function refresh() : void
      {
         this.determineVisibility();
      }
      
      private function handleWaterButtonClicked(e:MouseEvent) : void
      {
         UI.displayPopup(new GetMoreWaterWindow());
         FarmStatsManager.count("HUD","clicks","water_meter");
      }
   }
}

