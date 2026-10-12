package Display
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.MovieClip;
   
   public class GenericObjectPreviewPopup extends GenericPopup
   {
      
      private var m_item:FarmItem;
      
      public function GenericObjectPreviewPopup(item:FarmItem, message:String, type:int = 1, closeCallback:Function = null, dialogAsset:String = null)
      {
         super(message,type,closeCallback,dialogAsset,"",false,false,true);
         this.m_item = item;
         if(m_type == GenericPopup.TYPE_SHARE)
         {
            m_acceptTextName = "ShareItem";
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var sizeFactor:Number = NaN;
         m_window = m_loader.content as MovieClip;
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc))
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BONSAI_GARDEN) == Experiments.VARIANT_BONSAI_GARDEN_ON)
            {
               sizeFactor = this.m_item.sizeX == 1 && this.m_item.type == MasteryWindow.TYPE_TREE ? 2 : 10 / (this.m_item.sizeX + this.m_item.sizeY);
            }
            else
            {
               sizeFactor = 10 / (this.m_item.sizeX + this.m_item.sizeY);
            }
            new ObjectPreviewFrame(m_window.popupBox_mc.icon_mc,this.m_item,null,[sizeFactor]);
            if(m_window.popupBox_mc.share_bt)
            {
               m_window.popupBox_mc.share_bt.visible = true;
               m_accept = new GenericButton(m_window.popupBox_mc.share_bt,onAccept);
               m_accept.text = ZLocUtils.t("Dialogs",m_acceptTextName);
            }
         }
         setMessage();
         setupCloseButton();
         addChild(m_window);
      }
   }
}

