package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.TakePhotoEvent;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import Transactions.TTakePhoto;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   
   public class TakePhotoPopup extends Dialog
   {
      
      private var m_bmp:BitmapData;
      
      private var m_share:GenericButton;
      
      private var m_cancel:GenericButton;
      
      public function TakePhotoPopup(img:BitmapData)
      {
         m_dialogAsset = "assets/dialogs/FV_CameraPopUp.swf";
         super();
         this.m_bmp = img;
         FarmStatsManager.count("take_photo_popup","view");
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var data:Array = [];
         var m_img:Bitmap = new Bitmap(this.m_bmp);
         m_img.width = 295.8;
         m_img.height = 197.2;
         m_window.popupBox_mc.caption_tf.text = "";
         m_window.popupBox_mc.snapshot_mc.x -= 60;
         m_window.popupBox_mc.snapshot_mc.addChild(m_img);
         this.m_share = new GenericButton(m_window.popupBox_mc.share_bt,this.onAccept);
         this.m_share.text = ZLocUtils.t("Dialogs","Share");
         this.m_cancel = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancel);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Cancel");
         m_window.popupBox_mc.addCaption_tf.text = ZLocUtils.t("Dialogs","AddACaption");
         m_window.popupBox_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         var userid:String = null;
         var msg:String = m_window.popupBox_mc.caption_tf.text;
         dispatchEvent(new TakePhotoEvent(TakePhotoEvent.ACCEPT,msg));
         this.removeListeners();
         FarmStatsManager.count("take_photo_popup","accept_click");
         if(Global.worldManager.isVisiting() == true && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            userid = Global.worldManager.getVisiting();
         }
         else
         {
            userid = Global.player.uid;
         }
         TransactionManager.addTransaction(new TTakePhoto(userid));
      }
      
      protected function onCancel(event:MouseEvent) : void
      {
         if(event.target == m_window.popupBox_mc.close_bt)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         }
         dispatchEvent(new TakePhotoEvent(TakePhotoEvent.CANCEL,""));
         this.removeListeners();
         FarmStatsManager.count("take_photo_popup","cancel_click");
      }
      
      private function removeListeners() : void
      {
         m_window.popupBox_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         close();
         FarmStatsManager.count("take_photo_popup","cancel_click");
      }
   }
}

