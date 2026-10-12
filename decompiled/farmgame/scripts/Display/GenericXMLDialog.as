package Display
{
   import Events.GenericPopupEvent;
   import Managers.SmartPopupManager;
   import Widgets.View.Dialogs.DataDrivenDialogView;
   import flash.events.Event;
   
   public class GenericXMLDialog extends Dialog
   {
      
      public static const NUM_DIALOG_WIDTH_SMALL:Number = 300;
      
      public static const NUM_DIALOG_WIDTH_MEDIUM:Number = 415;
      
      public static const NUM_DIALOG_WIDTH_LARGE:Number = 590;
      
      public static const STR_BUTTON_NAME_CONFIRM:String = "confirm_bt";
      
      public static const STR_BUTTON_NAME_CANCEL:String = "cancel_bt";
      
      public static const STR_BUTTON_NAME_XBUTTON:String = "xbutton";
      
      public static const STR_BUTTON_NAME_MOREINFO:String = "info_bt";
      
      public static const STR_DEFAULT_TOP_TEXT_STYLE:String = ".h2";
      
      private var m_confirmCallback:Function;
      
      private var m_cancelCallback:Function;
      
      private var m_allInOneCloseCallback:Function;
      
      private var m_describeDialogOpen:Boolean = false;
      
      public var m_passedData:Object = null;
      
      private var m_confirmText:String = null;
      
      private var m_cancelText:String = null;
      
      private var m_infoText:String = null;
      
      public function GenericXMLDialog(sTitleText:String = null, sTopText:String = null, sTopTextStyle:String = null, sImageRelUrl:String = null, nImageWidth:Number = NaN, nImageHeight:Number = NaN, sBodyText:String = null, pAllInOneCloseCallback:Function = null, bXButton:Boolean = false, sConfirmButtonText:String = null, pConfirmCallback:Function = null, sCancelButtonText:String = null, pCancelCallback:Function = null, aPushMoreLocalizedParams:Array = null, nDialogWidth:Number = 415, sDialogAsset:String = "GenericXMLDialog", nDialogAssetType:Number = 101, modal:Boolean = true, bAddClickBlocker:Boolean = true, sInfoButtonText:String = null)
      {
         var i:Number = NaN;
         this.m_confirmCallback = pConfirmCallback;
         this.m_cancelCallback = pCancelCallback;
         this.m_allInOneCloseCallback = pAllInOneCloseCallback;
         if(this.m_allInOneCloseCallback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_allInOneCloseCallback);
         }
         m_dialogAsset = sDialogAsset;
         this.m_describeDialogOpen = true;
         this.m_confirmText = sConfirmButtonText;
         this.m_cancelText = sCancelButtonText;
         this.m_infoText = sInfoButtonText;
         var aParams:Array = [nDialogWidth.toString(),bXButton ? "true" : "false",sTitleText != null && sTitleText != "" ? "true" : "false",sTitleText,sTopText != null && sTitleText != "" ? "true" : "false",sTopText,sImageRelUrl != null && sImageRelUrl != "" ? "true" : "false",nImageWidth.toString(),nImageHeight.toString(),sImageRelUrl,sBodyText != null && sBodyText != "" ? "true" : "false",sBodyText,sConfirmButtonText != null ? "true" : "false",sConfirmButtonText,sCancelButtonText != null ? "true" : "false",sCancelButtonText,sTopTextStyle == null ? STR_DEFAULT_TOP_TEXT_STYLE : sTopTextStyle,sInfoButtonText != null ? "true" : "false",sInfoButtonText];
         if(aPushMoreLocalizedParams != null)
         {
            for(i = 0; i < aPushMoreLocalizedParams.length; i++)
            {
               aParams.push(aPushMoreLocalizedParams[i]);
            }
         }
         super(modal,bAddClickBlocker,nDialogAssetType,aParams);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var data:Array = [];
         var ddd:DataDrivenDialogView = getDataDrivenDialogView();
         if(ddd != null)
         {
            ddd.addButtonEventListener(STR_BUTTON_NAME_CONFIRM,this.onClickConfirmButton);
            ddd.addButtonEventListener(STR_BUTTON_NAME_CANCEL,this.onClickCancelButton);
            ddd.addButtonEventListener(STR_BUTTON_NAME_XBUTTON,this.onClickCancelButton);
            ddd.addButtonEventListener(STR_BUTTON_NAME_MOREINFO,this.onClickMoreInfoButton);
         }
      }
      
      protected function onClickMoreInfoButton(event:Event) : void
      {
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(m_trackerKey,this.m_infoText);
         }
         if(this.m_confirmCallback != null)
         {
            this.m_confirmCallback(event);
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.YES));
         if(this.m_allInOneCloseCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_allInOneCloseCallback);
         }
         this.close();
      }
      
      protected function onClickConfirmButton(event:Event) : void
      {
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(m_trackerKey,this.m_confirmText);
         }
         if(this.m_confirmCallback != null)
         {
            this.m_confirmCallback(event);
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.YES));
         if(this.m_allInOneCloseCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_allInOneCloseCallback);
         }
         this.close();
      }
      
      protected function onClickCancelButton(event:Event) : void
      {
         if(getTrackerEnabled())
         {
            if(this.m_cancelText == "" || this.m_cancelText == null)
            {
               this.m_cancelText = "X";
            }
            SmartPopupManager.getInstance().popupDeclined(m_trackerKey,this.m_cancelText);
         }
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback(event);
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO));
         if(this.m_allInOneCloseCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_allInOneCloseCallback);
         }
         this.close();
      }
      
      public function forceClose() : void
      {
         this.onClickCancelButton(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO));
      }
      
      override public function close() : void
      {
         this.m_describeDialogOpen = false;
         super.close();
      }
      
      public function get describeDialogOpen() : Boolean
      {
         return this.m_describeDialogOpen;
      }
      
      public function hasConfirmCallback() : Boolean
      {
         return this.m_confirmCallback != null;
      }
      
      public function hasCancelCallback() : Boolean
      {
         return this.m_cancelCallback != null;
      }
      
      public function hasAllInOneCloseCallback() : Boolean
      {
         return this.m_allInOneCloseCallback != null;
      }
   }
}

