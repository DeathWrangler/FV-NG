package Widgets.Windows.Crafting
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   
   public class GenericCraftingPopup extends GenericPopup
   {
      
      public function GenericCraftingPopup(message:String, type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenericPopUp.swf", rewardUrl:String = "", useHtmlText:Boolean = false)
      {
         super(message,type,closeCallback,dialogAsset,rewardUrl,useHtmlText);
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            m_cursorId = UI.setCursor(null);
            this.centerPopup();
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
      
      override protected function onHide() : void
      {
         if(m_shown == true)
         {
            m_shown = false;
            Utilities.toggleInputAndChildren(this,false);
            UI.removeCursor(m_cursorId);
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.removeEventListener(Event.RESIZE,onResize);
         }
         m_showOnLoad = false;
      }
   }
}

