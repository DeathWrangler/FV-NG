package Classes
{
   import Classes.Constants.CrossPromoConstants;
   
   public class CrossPromoDescriptor
   {
      
      private var m_promoName:String;
      
      private var m_dialogAsset:String;
      
      private var m_dialogAcceptText:String;
      
      private var m_playUrl:String;
      
      private var m_dialogBodyText:String;
      
      private var m_showCheckboxToRemoveItem:Boolean;
      
      private var m_billboardItemName:String;
      
      private var m_billboardItemToolTip:String;
      
      private var m_toasterAsset:String;
      
      private var m_toasterText:String;
      
      private var m_toasterTitle:String;
      
      private var m_gameID:String;
      
      private var m_npcFriendImage:String;
      
      private var m_npcId:String = "-1";
      
      private var m_hudIconId:int = -1;
      
      private var m_onClickRedirect:Boolean = false;
      
      private var m_billBoardPlayUrl:String;
      
      private var m_npcPlayUrl:String;
      
      private var m_toasterPlayUrl:String;
      
      private var m_openInSameWindow:Boolean;
      
      public function CrossPromoDescriptor(promoName:String, gameID:String, dialogAsset:String, dialogAcceptText:String, playUrl:String, billBoardPlayUrl:String, npcPlayUrl:String, toasterPlayUrl:String, openInSameWindow:Boolean, dialogBodyText:String = null, showCheckBoxToRemoveItem:Boolean = false, billboardItemName:String = null, billboardToolTip:String = null, toasterAsset:String = null, npcId:String = "-1", npcFriendImage:String = null, toasterTitle:String = null, toasterText:String = null, hudIconId:int = -1, onClickRedirect:Boolean = false)
      {
         super();
         this.m_promoName = promoName;
         this.m_gameID = gameID;
         this.m_dialogAsset = dialogAsset;
         this.m_dialogAcceptText = dialogAcceptText;
         this.m_billBoardPlayUrl = billBoardPlayUrl;
         this.m_npcPlayUrl = npcPlayUrl;
         this.m_toasterPlayUrl = toasterPlayUrl;
         this.m_playUrl = playUrl;
         this.m_dialogBodyText = dialogBodyText;
         this.m_showCheckboxToRemoveItem = showCheckBoxToRemoveItem;
         this.m_openInSameWindow = openInSameWindow;
         this.m_billboardItemName = billboardItemName;
         this.m_billboardItemToolTip = billboardToolTip;
         this.m_toasterAsset = toasterAsset;
         this.m_npcId = npcId;
         this.m_npcFriendImage = npcFriendImage;
         this.m_toasterTitle = toasterTitle;
         this.m_toasterText = toasterText;
         this.m_hudIconId = hudIconId;
         this.m_onClickRedirect = onClickRedirect;
      }
      
      public function get gameID() : String
      {
         return this.m_gameID;
      }
      
      public function get promoName() : String
      {
         return this.m_promoName;
      }
      
      public function get dialogAsset() : String
      {
         return this.m_dialogAsset;
      }
      
      public function get dialogAcceptText() : String
      {
         return this.m_dialogAcceptText;
      }
      
      public function get playUrl() : String
      {
         return this.m_playUrl;
      }
      
      public function get billBoardPlayUrl() : String
      {
         return this.m_billBoardPlayUrl;
      }
      
      public function get npcPlayUrl() : String
      {
         return this.m_npcPlayUrl;
      }
      
      public function get toasterPlayUrl() : String
      {
         return this.m_toasterPlayUrl;
      }
      
      public function get openInSameWindow() : Boolean
      {
         return this.m_openInSameWindow;
      }
      
      public function get targetWindow() : String
      {
         var result:String = "_blank";
         if(this.m_openInSameWindow || this.m_billboardItemName == "farmville2_xpromo_sign")
         {
            result = "_top";
         }
         return result;
      }
      
      public function get dialogBodyText() : String
      {
         return this.m_dialogBodyText;
      }
      
      public function get showCheckboxToRemoveItem() : Boolean
      {
         return this.m_showCheckboxToRemoveItem;
      }
      
      public function hasBillboard() : Boolean
      {
         return this.isPropertyValid(this.m_billboardItemName);
      }
      
      public function get billboardItemName() : String
      {
         return this.m_billboardItemName;
      }
      
      public function get billboardItemToolTip() : String
      {
         return this.m_billboardItemToolTip;
      }
      
      public function hasToaster() : Boolean
      {
         return this.isPropertyValid(this.m_toasterAsset);
      }
      
      public function get toasterTitle() : String
      {
         return this.m_toasterTitle;
      }
      
      public function get toasterText() : String
      {
         return this.m_toasterText;
      }
      
      public function get toasterAsset() : String
      {
         return this.m_toasterAsset;
      }
      
      public function get npcFriendImage() : String
      {
         return this.m_npcFriendImage;
      }
      
      public function get npcId() : String
      {
         return this.m_npcId;
      }
      
      public function hasNpc() : Boolean
      {
         return this.m_npcId != "-1";
      }
      
      public function get hudIconId() : int
      {
         return this.m_hudIconId;
      }
      
      public function hasHudIcon() : Boolean
      {
         return this.m_hudIconId != CrossPromoConstants.NOT_DEFINED;
      }
      
      public function get shouldRedirectOnClick() : Boolean
      {
         return this.m_onClickRedirect;
      }
      
      public function combineWithDescriptor(crossPromo:CrossPromoDescriptor) : void
      {
         if(this.isPropertyValid(crossPromo.dialogAsset))
         {
            this.m_dialogAsset = crossPromo.dialogAsset;
         }
         if(this.isPropertyValid(crossPromo.dialogAcceptText))
         {
            this.m_dialogAcceptText = crossPromo.dialogAcceptText;
         }
         if(this.isPropertyValid(crossPromo.playUrl))
         {
            this.m_playUrl = crossPromo.playUrl;
         }
         if(this.isPropertyValid(crossPromo.toasterPlayUrl))
         {
            this.m_toasterPlayUrl = crossPromo.toasterPlayUrl;
         }
         if(this.isPropertyValid(crossPromo.billBoardPlayUrl))
         {
            this.m_billBoardPlayUrl = crossPromo.billBoardPlayUrl;
         }
         if(this.isPropertyValid(crossPromo.npcPlayUrl))
         {
            this.m_npcPlayUrl = crossPromo.npcPlayUrl;
         }
         if(this.isPropertyValid(crossPromo.dialogBodyText))
         {
            this.m_dialogBodyText = crossPromo.dialogBodyText;
         }
         this.m_showCheckboxToRemoveItem = crossPromo.showCheckboxToRemoveItem;
         if(this.isPropertyValid(crossPromo.billboardItemName))
         {
            this.m_billboardItemName = crossPromo.billboardItemName;
         }
         if(this.isPropertyValid(crossPromo.billboardItemToolTip))
         {
            this.m_billboardItemToolTip = crossPromo.billboardItemToolTip;
         }
         if(this.isPropertyValid(crossPromo.toasterAsset))
         {
            this.m_toasterAsset = crossPromo.toasterAsset;
         }
         if(crossPromo.npcId != "-1")
         {
            this.m_npcId = crossPromo.npcId;
         }
         if(this.isPropertyValid(crossPromo.npcFriendImage))
         {
            this.m_npcFriendImage = crossPromo.npcFriendImage;
         }
         if(this.isPropertyValid(crossPromo.toasterTitle))
         {
            this.m_toasterTitle = crossPromo.toasterTitle;
         }
         if(this.isPropertyValid(crossPromo.toasterText))
         {
            this.m_toasterText = crossPromo.toasterText;
         }
         if(crossPromo.hudIconId != CrossPromoConstants.NOT_DEFINED)
         {
            this.m_hudIconId = crossPromo.hudIconId;
         }
         this.m_onClickRedirect = crossPromo.shouldRedirectOnClick;
         this.m_openInSameWindow = crossPromo.openInSameWindow;
      }
      
      private function isPropertyValid(property:String) : Boolean
      {
         return property != null && property.length > 0;
      }
   }
}

