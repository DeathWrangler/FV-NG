package Display.HUD.HUDWidgets
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Interfaces.IZwEventHandling;
   import Widgets.Core.Managers.ZwEventManager;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class VillageFTUEHudIcon extends HUDWidget implements IZwEventHandling
   {
      
      private static const FTUE_HUD_ICON_ASSET:String = "assets/dialogs/Village/HUD/HUD_village_FTUE.swf";
      
      private static const FTUE_HUD_ICON_TOOLTIP:String = "FarmVillage_FTUE_icon_tooltip";
      
      private var m_callback:Function;
      
      private var m_tooltip:FarmTextTooltip;
      
      protected var m_eventManager:ZwEventManager = new ZwEventManager();
      
      public function VillageFTUEHudIcon(parentElement:Sprite, onClickCallback:Function)
      {
         super(FTUE_HUD_ICON_ASSET,parentElement);
         this.m_callback = onClickCallback;
         this.registerEventListener(MouseEvent.CLICK,this.onClick);
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_tooltip = new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,FTUE_HUD_ICON_TOOLTIP));
         this.m_tooltip.attach(this);
      }
      
      private function onMouseOver(event:Event) : void
      {
         if(m_element)
         {
            if(m_element["wave_mc"])
            {
               if(m_element.wave_mc["wave2_mc"])
               {
                  (m_element.wave_mc.wave2_mc as MovieClip).play();
               }
               (m_element.wave_mc as MovieClip).play();
            }
         }
      }
      
      public function showProgressAnimation() : void
      {
         if(m_element)
         {
            if(m_element["wave_mc"])
            {
               if(m_element.wave_mc["wave2_mc"])
               {
                  (m_element.wave_mc.wave2_mc as MovieClip).play();
               }
               (m_element.wave_mc as MovieClip).play();
            }
            if(m_element["giftfireworks_mc"])
            {
               (m_element.giftfireworks_mc as MovieClip).gotoAndPlay(1);
            }
         }
      }
      
      private function onClick(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      override public function release() : void
      {
         if(this.m_tooltip)
         {
            this.m_tooltip.release();
            this.m_tooltip = null;
         }
         if(this.m_eventManager)
         {
            this.m_eventManager.release();
            this.m_eventManager = null;
         }
         this.m_callback = null;
         super.release();
         m_parentElement = null;
      }
      
      final public function registerEventListener(eventType:String, callback:Function) : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.registerEventListener(m_parentElement,eventType,callback);
         }
      }
      
      final public function unregisterEventListener(eventType:String, callback:Function) : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.unregisterEventListener(m_parentElement,eventType,callback);
         }
      }
   }
}

