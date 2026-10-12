package Display.HUD
{
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Events.FarmGameWorldEvent;
   import Managers.LoyaltyProgramManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.LoyaltyProgramWindow;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LoyaltyProgramButton extends ZwAbstractWindow
   {
      
      private static const X_POSITION:Number = 575;
      
      private static const Y_POSITION:Number = 47;
      
      private const ASSET_PATH:String = "assets/hud/FV_LoyaltyProgram2013_HUD.swf";
      
      private var m_loyaltyButton:FarmAnimatedTextButton;
      
      private var m_goldenButton:FarmAnimatedTextButton;
      
      public function LoyaltyProgramButton()
      {
         super(Global.getAssetURL(this.ASSET_PATH));
      }
      
      private static function handleLoyaltyProgramButtonClicked(e:MouseEvent) : void
      {
         UI.displayPopup(new LoyaltyProgramWindow());
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.x = X_POSITION;
         this.y = Y_POSITION;
         if("loyalty_bt" in m_window)
         {
            this.m_loyaltyButton = new FarmAnimatedTextButton(m_window.loyalty_bt,"",handleLoyaltyProgramButtonClicked);
            addWidget(this.m_loyaltyButton,false);
         }
         if("loyalty2_bt" in m_window)
         {
            this.m_goldenButton = new FarmAnimatedTextButton(m_window.loyalty2_bt,"",handleLoyaltyProgramButtonClicked);
            addWidget(this.m_goldenButton,false);
         }
         if(Global.player.postInitFinished)
         {
            this.determineVisibility();
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.determineVisibility);
         }
      }
      
      private function determineVisibility(e:Event = null) : void
      {
         var buttonToUse:FarmAnimatedTextButton = null;
         var visibility:Boolean = false;
         if(LoyaltyProgramManager.getInstance().userPassesPrereq() && Global.player.postInitFinished)
         {
            buttonToUse = LoyaltyProgramManager.getInstance().isGoldenFarmer() ? this.m_goldenButton : this.m_loyaltyButton;
            if(buttonToUse)
            {
               buttonToUse.visible = true;
               buttonToUse.text = LoyaltyProgramManager.getInstance().getGoldenFarmerStatusText();
               if(buttonToUse.tooltip)
               {
                  buttonToUse.detachTooltip();
               }
               buttonToUse.attachTooltip(new MarketTooltip(LoyaltyProgramManager.getInstance().getGoldenFarmerStatusTooltipText()));
               visibility = true;
               Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.determineVisibility);
            }
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
   }
}

