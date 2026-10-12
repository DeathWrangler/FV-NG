package Widgets.Windows.Crafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import GameMode.GMBuild;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class FirstMarketStallWindow extends FarmWindow
   {
      
      public static const SEEN_FLAG:String = "FirstMarketStall";
      
      protected var m_MarketStallBuilding:MarketStallBuilding;
      
      protected var m_bushelCode:String = "";
      
      protected var m_iconFrame:ZwFrame;
      
      public function FirstMarketStallWindow(bushelCode:String)
      {
         super("assets/dialogs/FV_Feature_Callout.swf");
         this.m_bushelCode = bushelCode;
      }
      
      public static function getFirstMarketStallSeenFlag() : String
      {
         var result:String = SEEN_FLAG;
         var currentWorldType:String = Global.worldManager.currentWorldType;
         if(currentWorldType != WorldsConstants.WORLD_ID_HOME)
         {
            result = result + "_" + currentWorldType;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwFrame(m_window.popupBox_mc));
         var bodyTextField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf,this.getBodyText());
         var textFormat:TextFormat = bodyTextField.getTextFormat();
         textFormat.align = "center";
         bodyTextField.setTextFormat(textFormat);
         addWidget(bodyTextField);
         this.m_iconFrame = new ZwFrame(m_window.popupBox_mc.icon_mc);
         addWidget(this.m_iconFrame);
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelCode);
         LoadingManager.load(bushelItem.icon,this.onIconLoaded);
         addWidget(new FarmAnimatedTextButton(m_window.popupBox_mc.okay_bt,this.getButtonText(),this.onOkayClicked));
      }
      
      protected function getBodyText() : String
      {
         return ZLocUtils.t("Crafting","FirstMarketStallDialog_Body");
      }
      
      protected function getButtonText() : String
      {
         return ZLocUtils.t("FarmGame","OK");
      }
      
      protected function startGameMode() : void
      {
         if(CraftingManager.getInstance().lastBushelFound != null)
         {
            CraftingManager.getInstance().reconfigureOnPlace = true;
         }
         Global.world.addGameMode(new GMBuild("marketstall",true,0,false));
      }
      
      protected function setSeenFlag() : void
      {
         Global.player.setSeenFlag(FirstMarketStallWindow.getFirstMarketStallSeenFlag());
      }
      
      protected function onOkayClicked(e:MouseEvent) : void
      {
         this.close();
         this.setSeenFlag();
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         this.m_iconFrame.element.scaleX = this.m_iconFrame.element.scaleY = 1;
         while(this.m_iconFrame.element.numChildren)
         {
            this.m_iconFrame.element.removeChildAt(0);
         }
         var newIcon:DisplayObject = event.currentTarget.content;
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         this.m_iconFrame.element.addChild(newIcon);
      }
      
      override public function close() : void
      {
         var dispObj:DisplayObject = this;
         hideTween(function():void
         {
            release();
            dispatchEvent(new Event(Event.CLOSE));
         });
         onHide();
         this.startGameMode();
      }
      
      override public function hide() : void
      {
         hideTween(function():void
         {
            this.visible = false;
         });
         onHide();
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            if(m_modal)
            {
               InputManager.disableInput();
               Utilities.toggleInputAndChildren(Global.ui,false);
            }
            m_cursorId = UI.setCursor(null);
            Utilities.toggleInputAndChildren(this,true);
            m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,onResize);
         }
         else
         {
            m_showOnLoad = true;
         }
         SoundManager.playSound("dialogSpawn");
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_iconFrame = null;
      }
   }
}

