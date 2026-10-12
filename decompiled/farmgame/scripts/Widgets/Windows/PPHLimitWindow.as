package Widgets.Windows
{
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.ExpansionPlotLimits;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.Loader;
   import flash.events.Event;
   
   public class PPHLimitWindow extends FarmWindow
   {
      
      public static const PPH_LIMIT_REACHED_DIALOG:String = "pphlimit_reached_dialog";
      
      public static const PPH_LIMIT_WARNING_PLOW_DIALOG:String = "pphlimit_warning_plow_dialog";
      
      public static const PPH_LIMIT_WARNING_TRACTOR_DIALOG:String = "pphlimit_warning_tractor_dialog";
      
      public static const PPH_LIMIT_WARNING_TYPE:String = "limit_warning";
      
      public static const PPH_LIMIT_REACHED_TYPE:String = "limit_reached";
      
      public static const PPH_WINDOW_CONFIG:Object = {
         "fisherman":"assets/dialogs/FV_Support/FV_Expansions_Features/Cove/PPHLimit/",
         "winterwonderland":"assets/dialogs/FV_Support/FV_Expansions_Features/WinterWonderland/PPHLimit/",
         "hawaii":"assets/dialogs/FV_Support/FV_Expansions_Features/Hawaii/PPHLimit/",
         "asia":"assets/dialogs/FV_Support/FV_Expansions_Features/Asia/PPHLimit/",
         "hallow":"assets/dialogs/FV_Support/FV_Expansions_Features/Hallow/PPHLimit/",
         "htown":"assets/dialogs/FV_Support/FV_Expansions_Features/HTown/PPHLimit/"
      };
      
      private var m_checkMark:PPHLimitCheckMark;
      
      private var m_isSelected:Boolean = true;
      
      private var m_dialogType:String;
      
      private var m_terrainCode:int = 0;
      
      private var m_nextExpansionChangeFarmItem:ChangeFarmItem = Global.worldManager.getNextExpansion();
      
      public function PPHLimitWindow(type:String = "limit_warning", terrainCode:int = 0)
      {
         this.m_dialogType = type;
         this.m_terrainCode = terrainCode;
         super("assets/dialogs/FV_PPHLimit.swf");
      }
      
      private function getFailoverString(pkg:String, worldType:String, key:String, params:Object = null) : String
      {
         return ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(pkg,worldType + "_" + key),new ZLocFailoverEntry(pkg,key)],params);
      }
      
      override protected function postLoadComplete() : void
      {
         var bodyText:String = null;
         var buttonText:String = null;
         var closeButton:FarmButton = null;
         var key:String = null;
         var imagePathName:String = null;
         var plotLimitGroupName:String = Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode);
         var worldType:String = Global.worldManager.currentWorldType;
         var fullyExpanded:Boolean = Global.worldManager.isAtMaxExpansion();
         addWidget(new ZwWidget(m_window.popupBox_mc));
         addWidget(new ZwTextField(m_window.popupBox_mc.goldTitle_tf,this.getFailoverString("Dialogs",worldType,"pphlimit_title")));
         this.m_checkMark = new PPHLimitCheckMark(m_window.popupBox_mc.checkbox1_mc);
         addWidget(this.m_checkMark);
         var checkBoxText:ZwTextField = new ZwTextField(m_window.popupBox_mc.checkbox_tf,this.getFailoverString("Dialogs",worldType,"pphlimit_checkbox"));
         closeButton = new FarmButton(m_window.popupBox_mc.close_bt,this.onClose);
         var params:Object = {"quantity":Global.worldManager.getCurrentPlotLimit(this.m_terrainCode)};
         var allLimits:Array = null;
         var currentSquares:String = String(Global.world.getGridWidth());
         var buttonCallback:Function = this.onClose;
         if(currentSquares)
         {
            allLimits = Global.worldManager.getPlotLimitsForSquares(currentSquares);
            for(key in allLimits)
            {
               params[Global.worldManager.getLimitGroupNameByLimitGroupIndex(int(key)) + "_quantity"] = allLimits[key];
            }
         }
         if(this.m_dialogType == PPH_LIMIT_WARNING_TYPE)
         {
            this.setImage(PPH_WINDOW_CONFIG[worldType] + "PPH_Dialog_Intro.png");
            bodyText = this.getFailoverString("Dialogs",worldType,"pphlimit_warning_body",params);
            buttonText = this.getFailoverString("Dialogs",worldType,"pphlimit_warning_button");
            buttonCallback = this.onClose;
            this.m_checkMark.visible = false;
            checkBoxText.visible = false;
            closeButton.visible = false;
         }
         else if(this.m_dialogType == PPH_LIMIT_REACHED_TYPE)
         {
            imagePathName = PPH_WINDOW_CONFIG[worldType] + "PPH_Dialog_Reached.png";
            if(plotLimitGroupName != ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME)
            {
               imagePathName = PPH_WINDOW_CONFIG[worldType] + "PPH_Dialog_Reached_" + plotLimitGroupName + ".png";
            }
            this.setImage(imagePathName);
            bodyText = this.getFailoverString("Dialogs",worldType,"pphlimit_reached_body",params);
            buttonText = this.getFailoverString("Dialogs",worldType,"pphlimit_reached_button");
            buttonCallback = this.onAccept;
            addWidget(closeButton);
         }
         if(fullyExpanded)
         {
            bodyText = this.getFailoverString("Dialogs",worldType,"pphlimit_reached_noexpand",params);
            buttonText = this.getFailoverString("Dialogs",worldType,"pphlimit_reached_button");
            buttonCallback = this.onClose;
         }
         addWidget(new ZwTextField(m_window.popupBox_mc.body_tf,bodyText));
         addWidget(new ZwTextField(m_window.popupBox_mc.accept_bt.generic_tf,buttonText));
         addWidget(new FarmButton(m_window.popupBox_mc.accept_bt,buttonCallback));
         FarmStatsManager.count("pph_limit","limit-reached","view","",this.m_dialogType,plotLimitGroupName);
      }
      
      private function onAccept(event:Event) : void
      {
         var plotLimitGroupName:String = Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode);
         FarmStatsManager.count("pph_limit","prompt_to_expand","click","expand",this.m_dialogType,plotLimitGroupName);
         super.onClose(event);
         UI.displayMarketDialog("lot_text","change_farm",null,"expand_farm");
         event.stopImmediatePropagation();
         event.stopPropagation();
         if(this.m_checkMark.checkSelected)
         {
            Global.player.setSeenFlag(PPH_LIMIT_REACHED_DIALOG);
            FarmStatsManager.count("pph_limit","prompt_to_expand","suppress",this.m_dialogType,plotLimitGroupName);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         var plotLimitGroupName:String = Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode);
         FarmStatsManager.count("pph_limit","prompt_to_expand","click","close",this.m_dialogType,plotLimitGroupName);
         if(this.m_checkMark.checkSelected)
         {
            Global.player.setSeenFlag(PPH_LIMIT_REACHED_DIALOG);
            FarmStatsManager.count("pph_limit","prompt_to_expand","suppress",this.m_dialogType,plotLimitGroupName);
         }
      }
      
      private function setImage(url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(Global.getAssetURL(url),function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               m_window.popupBox_mc.image_mc.addChild(dispObj);
            }
         });
      }
   }
}

