package Display
{
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   
   public class GenericBuyPreviewPopup extends GenericPopup
   {
      
      private var m_item:FarmItem;
      
      protected var m_itemSwf:String;
      
      public function GenericBuyPreviewPopup(item:FarmItem, message:String, type:int = 1, closeCallback:Function = null, itemSwf:String = "")
      {
         this.m_item = item;
         this.m_itemSwf = itemSwf;
         super(message,type,closeCallback,"assets/dialogs/turtleisland/innovation/FV_xti_Innovation_previewWindow.swf","",false,true,true);
      }
      
      override protected function onLoadComplete() : void
      {
         var url:String = null;
         var icon:FarmIcon = null;
         m_window = m_loader.content as MovieClip;
         if(m_window)
         {
            if(m_window.icon_mc)
            {
               if(Boolean(this.m_itemSwf) || this.m_item is ConsumableItem)
               {
                  url = this.m_item.imageRelativeUrl("feed");
                  icon = new FarmIcon(m_window.icon_mc,url);
                  icon.setIconHeight(200);
                  icon.setIconWidth(200);
               }
               else
               {
                  new ObjectPreviewFrame(m_window.icon_mc,this.m_item,null,null,[200]);
               }
            }
            if(m_window.name_tf)
            {
               new FarmTextField(m_window.name_tf,this.m_item.friendlyTitle);
            }
         }
         setupCloseButton();
         addChild(m_window);
      }
   }
}

