package Widgets.Windows.DecoPoints
{
   import Classes.PhotoGalleryImageData;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class DecoPointsGallerySlot extends ZwFrame
   {
      
      private var m_data:PhotoGalleryImageData;
      
      private var m_icon:FarmIcon;
      
      private var m_flagBtn:FarmAnimatedButton;
      
      private var m_voteBtn:FarmAnimatedTextButton;
      
      private var m_flagMode:ZwBaseWidget;
      
      private var m_callback:Function;
      
      public function DecoPointsGallerySlot(element:DisplayObject, callBack:Function)
      {
         super(element);
         this.m_callback = callBack;
         if(m_element.icon_mc)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc),false) as FarmIcon;
         }
         if(m_element.flag_bt)
         {
            this.m_flagBtn = addWidget(new FarmAnimatedButton(m_element.flag_bt,this.onFlagImage)) as FarmAnimatedButton;
         }
         if(m_element.flag_mc)
         {
            this.m_flagMode = addWidget(new ZwBaseWidget(m_element.flag_mc),false) as ZwBaseWidget;
         }
         if(m_element.vote_bt)
         {
            this.m_voteBtn = addWidget(new FarmAnimatedTextButton(m_element.vote_bt,ZLocUtils.t("Dialogs","DPVoteTab_Vote"),this.onVoteImage),true) as FarmAnimatedTextButton;
         }
      }
      
      private function onVoteImage(event:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(DecoPointsManager.SUBMIT_GALLERY_VOTE,this);
            FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.MODE_VOTE);
         }
      }
      
      private function onFlagConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            if(this.m_callback != null)
            {
               this.m_callback(DecoPointsManager.SUBMIT_GALLERY_ABUSE,this);
               FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_FLAG_CONTENT);
            }
         }
         else
         {
            this.enableUI();
         }
      }
      
      public function loadIconToVote(index:Number) : void
      {
         var photoImageData:PhotoGalleryImageData = DecoPointsManager.instance.getNextContestPhotoToVote(index);
         if(photoImageData != null)
         {
            this.m_data = photoImageData;
            if(this.m_icon != null)
            {
               this.m_icon.loadIcon(DecoPointsManager.getFullImageUrl(photoImageData.imageUrl));
               this.m_icon.setIconSize(200,200);
               this.m_icon.visible = true;
            }
         }
         else
         {
            this.disableUI();
         }
      }
      
      public function disableUI() : void
      {
         if(this.m_voteBtn != null)
         {
            this.m_voteBtn.enabled = false;
         }
         if(this.m_flagBtn != null)
         {
            this.m_flagBtn.enabled = false;
         }
         if(this.m_icon != null)
         {
            this.m_icon.visible = false;
         }
      }
      
      public function enableUI() : void
      {
         this.enabled = true;
         this.m_voteBtn.enabled = true;
         this.m_flagBtn.enabled = true;
         this.m_icon.visible = true;
         this.m_flagMode.visible = false;
      }
      
      private function onFlagImage(event:MouseEvent) : void
      {
         this.m_flagMode.visible = true;
         this.enableFlagMode();
      }
      
      private function enableFlagMode() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","DPVoteTab_FlagConfirmation"),GenericPopup.TYPE_ACCEPTCANCEL,this.onFlagConfirmation);
      }
      
      public function get data() : PhotoGalleryImageData
      {
         return this.m_data;
      }
      
      public function resetSlotData() : void
      {
         this.m_data = null;
         this.m_icon.visible = false;
      }
   }
}

