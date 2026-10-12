package Display.FriendBar
{
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FleaMarket.FleaMarketWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DynamicNPCSlot extends NPCSlot
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_configObject:Object;
      
      private var m_statsCounter:String = null;
      
      private var m_widgetManager:ZwWidgetManager = new ZwWidgetManager();
      
      public function DynamicNPCSlot(slotIndex:int, configObject:Object)
      {
         this.m_configObject = configObject;
         GlobalEngine.assert(configObject.hasOwnProperty("assetPath"),"Cannot create DynamicNPCSlot without an asset");
         GlobalEngine.assert(configObject.hasOwnProperty("action"),"Cannot create DynamicNPCSlot without an action");
         var assetURL:String = configObject.assetPath;
         LoadingManager.load(Global.getAssetURL(assetURL),this.onBackgroundLoaded);
         this.m_statsCounter = configObject.hasOwnProperty("stat") ? configObject.stat : configObject.action;
         super(slotIndex);
         if(Boolean(m_backgroundNormal) && contains(m_backgroundNormal))
         {
            removeChild(m_backgroundNormal);
         }
      }
      
      private function onBackgroundLoaded(event:Event) : void
      {
         var farmIcon:FarmIcon = null;
         var tooltipText:String = this.m_configObject.hasOwnProperty("tooltip") ? ZLocUtils.t_pk(this.m_configObject.tooltip) : "";
         var loadedBackImage:MovieClip = event.target.content as MovieClip;
         this.isSpecialFriendSlot = true;
         m_sprite = new FarmGameSprite();
         m_sprite.addChild(loadedBackImage);
         m_sprite.toolTip = tooltipText;
         addChild(m_sprite);
         if(this.m_configObject.hasOwnProperty("dynamicIcon") && loadedBackImage.hasOwnProperty("icon_mc"))
         {
            farmIcon = new FarmIcon(loadedBackImage.icon_mc);
            farmIcon.loadIcon(this.m_configObject.dynamicIcon);
            farmIcon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_widgetManager.addWidget(farmIcon);
         }
         if(this.m_configObject.hasOwnProperty("title") && loadedBackImage.hasOwnProperty("title_tf"))
         {
            this.m_widgetManager.addWidget(new ZwTextField(loadedBackImage.title_tf,ZLocUtils.t_pk(this.m_configObject.title)));
         }
         FarmStatsManager.count(this.m_statsCounter,"neighbor_bar","view");
      }
      
      override protected function onRollOverFriend(e:MouseEvent) : void
      {
         if(Global.worldManager.getVisiting() == uid.toString())
         {
            m_sprite.hideToolTip();
         }
      }
      
      override protected function refreshCardBitmaps() : void
      {
      }
      
      override public function refresh() : void
      {
         var refreshCallbackParams:Object = null;
         if(this.m_configObject.hasOwnProperty("refreshCallback"))
         {
            refreshCallbackParams = this.m_configObject.hasOwnProperty("refreshParams") ? this.m_configObject.refreshParams : null;
            (this.m_configObject.refreshCallback as Function)(refreshCallbackParams);
         }
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         var dialog:FleaMarketWindow = null;
         FarmStatsManager.count(this.m_statsCounter,"neighbor_bar","click");
         switch(this.m_configObject.action)
         {
            case "flea_market":
               if(!Global.worldManager.isVisiting())
               {
                  dialog = new FleaMarketWindow();
                  UI.displayPopup(dialog,false,"FleaMarketWindow",true);
               }
               break;
            default:
               if(this.m_configObject.hasOwnProperty("onClickSlot"))
               {
                  (this.m_configObject.onClickSlot as Function)();
               }
         }
      }
   }
}

