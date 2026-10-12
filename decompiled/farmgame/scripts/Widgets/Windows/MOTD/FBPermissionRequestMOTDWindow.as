package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TConfirmFbPermissionRequest;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class FBPermissionRequestMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_PermissionCollection.swf";
      
      private static const MAX_PERMISSION_PER_DIALOG:Number = 3;
      
      private static const MTOD_X_OFFSET:Number = 75;
      
      private var m_permissionRequestList:Object;
      
      private var m_finalPermissionsRequest:Array = new Array();
      
      public function FBPermissionRequestMOTDWindow()
      {
         super(ASSET_URL);
         ExternalInterface.addCallback("fbPermissionRequestPostAction",fbPermissionRequestPostAction);
      }
      
      public static function fbPermissionRequestPostAction(permRequestResult:Object) : void
      {
         if(Boolean(permRequestResult) && Boolean(permRequestResult.requestSuccess))
         {
            TransactionManager.addTransaction(new TConfirmFbPermissionRequest(true),true);
            FarmStatsManager.count("fv_permission_collection_prompt","permissions_granted");
         }
         else
         {
            FarmStatsManager.count("fv_permission_collection_prompt","permissions_not_granted");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String;
         var subTitleText:String;
         var okButtonText:String;
         var itemName:String;
         var permissionListCounter:Number;
         var item:FarmItem = null;
         var key:* = undefined;
         var entryTitleName:String = null;
         var entryDescName:String = null;
         super.postLoadComplete();
         m_window.x -= MTOD_X_OFFSET;
         try
         {
            this.m_permissionRequestList = com.adobe.serialization.json.JSON.decode(Global.flashHotParams["FB_PERMISSION_REQUEST_LIST"]);
         }
         catch(error:Error)
         {
            FarmStatsManager.count("fv_permission_collection_prompt","error","couldNotConvertPermissionRequestListToObject");
         }
         titleText = ZLocUtils.t("Dialogs","MOTD_FBPermission_title");
         subTitleText = ZLocUtils.t("Dialogs","MOTD_FBPermission_subTitle");
         okButtonText = ZLocUtils.t("Dialogs","MOTD_FBPermission_okButtonText");
         if(Boolean(m_window.title_tf && m_window.okay_bt) && Boolean(titleText) && Boolean(okButtonText))
         {
            addWidget(new FarmTextField(m_window.title_tf,titleText));
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,okButtonText,this.onClickOkay));
         }
         if(m_window.whatsNew_tf)
         {
            addWidget(new FarmTextField(m_window.whatsNew_tf,subTitleText));
         }
         if(m_window.learnMore_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.learnMore_bt,"Learn More",this.onClicklearnMore));
         }
         itemName = Global.flashHotParams["FB_PERMISSION_COLLECTION_ITEMNAME"];
         if(itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(Boolean(m_window.incentive_mc) && Boolean(item) && Boolean(item.icon))
            {
               addWidget(new FarmIcon(m_window.incentive_mc,item.icon));
            }
            if(Boolean(m_window.generic_tf) && Boolean(item))
            {
               addWidget(new FarmTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","MOTD_FBPermission_body",{"itemName":ZLocUtils.tk_pk_asTitle(item.friendlyName)})));
            }
         }
         permissionListCounter = 0;
         if(Global.player.unacceptedFbPermissions)
         {
            for(key in Global.player.unacceptedFbPermissions)
            {
               entryTitleName = "perTitle" + permissionListCounter + "_tf";
               entryDescName = "perDescription" + permissionListCounter + "_tf";
               if(Boolean(this.m_permissionRequestList[key]) && Boolean(this.m_permissionRequestList[key].title) && Boolean(this.m_permissionRequestList[key].desc) && Boolean(m_window[entryTitleName]) && Boolean(m_window[entryDescName]))
               {
                  addWidget(new FarmTextField(m_window[entryTitleName],this.m_permissionRequestList[key].title.toString()));
                  this.m_finalPermissionsRequest.push(key);
                  FarmStatsManager.count("fv_permission_collection_prompt","info","permissionShown","" + String(key) + "");
                  if(++permissionListCounter == MAX_PERMISSION_PER_DIALOG)
                  {
                     break;
                  }
               }
               else
               {
                  FarmStatsManager.count("fv_permission_collection_prompt","error","swfOrPermRequestListIsNotValid");
               }
            }
         }
         FarmStatsManager.count("fv_permission_collection_prompt","dialog_impression");
      }
      
      private function onClickOkay(event:MouseEvent) : void
      {
         ExternalInterface.call("FarmNS.Request2Manager.permissionRequest",this.m_finalPermissionsRequest.toString());
         FarmStatsManager.count("fv_permission_collection_prompt","ok_button");
         super.onClose(event);
      }
      
      private function onClicklearnMore(event:Event) : void
      {
         var key:* = undefined;
         var entryTitleName:String = null;
         var entryDescName:String = null;
         var content:String = "";
         var permissionListCounter:Number = 0;
         for(key in Global.player.unacceptedFbPermissions)
         {
            entryTitleName = "perTitle" + permissionListCounter + "_tf";
            entryDescName = "perDescription" + permissionListCounter + "_tf";
            if(Boolean(this.m_permissionRequestList[key]) && Boolean(this.m_permissionRequestList[key].title) && Boolean(this.m_permissionRequestList[key].desc))
            {
               content += this.m_permissionRequestList[key].title + "\n" + this.m_permissionRequestList[key].desc;
               if(++permissionListCounter == MAX_PERMISSION_PER_DIALOG)
               {
                  break;
               }
               content += "\n\n";
            }
         }
         UI.showMessage(content,UI.BUTTON_LAYOUT_NONE);
         FarmStatsManager.count("fv_permission_collection_prompt","learnmore_impression");
      }
   }
}

