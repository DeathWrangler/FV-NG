package Widgets.Windows
{
   import Classes.MarketIndicatorConfig;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MarketIndicatorWindow extends FarmWindow
   {
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_NewToMarket.swf";
      
      private const ICON_WIDTH:int = 100;
      
      private const ICON_HEIGHT:int = 85;
      
      private const MOUSE_EVENT_UP_PRIORITY:int = 2;
      
      private var m_onCloseCallback:Function;
      
      public function MarketIndicatorWindow(onCloseCallback:Function)
      {
         super(this.DIALOG_ASSET);
         this.m_onCloseCallback = onCloseCallback;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(new ZwTextField(m_window.generic1_tf,ZLocUtils.t("Dialogs","MarketIndicatorTitleLine1")));
         addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","MarketIndicatorTitleLine2")));
         var icon:FarmIcon = new FarmIcon(m_window.icon_mc,MarketIndicatorConfig.getInstance().iconUrl);
         icon.setIconSize(this.ICON_WIDTH,this.ICON_HEIGHT);
         icon.element.addEventListener(MouseEvent.MOUSE_UP,this.onClick,false,this.MOUSE_EVENT_UP_PRIORITY);
         icon.element.buttonMode = true;
         icon.element.useHandCursor = true;
         addWidget(icon);
         getWidget(m_window.close_bt).addEventListener(MouseEvent.MOUSE_UP,this.onClose,false,this.MOUSE_EVENT_UP_PRIORITY);
         MarketIndicatorConfig.getInstance().setSeen();
         MarketIndicatorConfig.getInstance().logStatsImpression();
      }
      
      private function onClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         event.stopImmediatePropagation();
         var marketConfig:MarketIndicatorConfig = MarketIndicatorConfig.getInstance();
         marketConfig.logStatsClick();
         UI.displayMarketDialog("marketIndicator",marketConfig.marketCategory,null,marketConfig.marketSubcategory);
         close();
         this.m_onCloseCallback();
      }
      
      override protected function onClose(event:Event) : void
      {
         event.stopPropagation();
         event.stopImmediatePropagation();
         super.onClose(event);
         this.m_onCloseCallback();
      }
      
      override protected function release() : void
      {
         getWidget(m_window.icon_mc).removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
         getWidget(m_window.close_bt).removeEventListener(MouseEvent.MOUSE_UP,this.onClose);
         super.release();
      }
   }
}

