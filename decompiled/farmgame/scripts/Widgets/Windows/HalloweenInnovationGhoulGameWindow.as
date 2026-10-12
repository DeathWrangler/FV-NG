package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.HalloweenInnovationGhoulConsumableFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import mx.utils.StringUtil;
   
   public class HalloweenInnovationGhoulGameWindow extends FarmWindowWithTutorial
   {
      
      private static const KEY_HAS_FINISHED_PART:String = "hasFinishedPart";
      
      private static const KEY_HAS_FINISHED_INVENTION:String = "hasFinishedInvention";
      
      private static const KEY_HAS_FINISHED_GAME:String = "hasFinishedGame";
      
      private static const KEY_ERROR:String = "error";
      
      private static const KEY_ERROR_ISF:String = "ISF";
      
      private static const NA:String = "NA";
      
      private static const CELL_WIDTH:int = 45;
      
      private static const CELL_HEIGHT:int = 45;
      
      private static const OWL_ANIM_MC:String = "owlAnim_mc";
      
      private static const OWL_STATIC_MC:String = "owlStatic_mc";
      
      private static const NUM_TUTORIAL_SCENES:Number = 3;
      
      private const FEATURE_NAME:String = "HalloweenInnovationGhoul";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const SUBTEXT_TF:String = "subtext_tf";
      
      private const REWARD_MC:String = "reward_mc";
      
      private const REWARD_NAME_TF:String = "rewardname_tf";
      
      private const WHAT_IS_THIS_MC:String = "whatisthis_mc";
      
      private const TUTORIAL_MC:String = "tutorial_mc";
      
      private const DOOBER_MC:String = "doober_mc";
      
      private const REFERENCE_MC:String = "reference_mc";
      
      private const PART_REF_MC:String = "part_ref_mc";
      
      private const HIGHLIGHT_MC:String = "highlight_mc";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const COMPLETEPART_MC:String = "completepart_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const GRID_MC:String = "grid_mc";
      
      private const NUM_GRID_IMAGES:int = 4;
      
      private const NUM_GRIDS_ROW:int = 10;
      
      private const NUM_GRIDS_COL:int = 12;
      
      private const CONGRATS_MC:String = "congrats_mc";
      
      private const CONGRATS1_TF:String = "congrats1_tf";
      
      private const CONGRATS2_TF:String = "congrats2_tf";
      
      private const PLAYNEXT_TF:String = "playnext_tf";
      
      private const PLAYNEXT_BT:String = "next_bt";
      
      private const IMAGE_PREVIEW_MC:String = "imagepreview_mc";
      
      private const CONSUMABLE_MC:String = "activeGame_mc";
      
      private const INSUFFICIENT_FIREBOLT:String = "ISF";
      
      private const NUM_FIREBOLT_REQUIRED:Number = 1;
      
      private const NUM_FIREBOLT_GAINED:Number = 2;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Let\'s go!"];
      
      private const HALLOWEEN_GHOUL_GAME_FTUE_FLAG:String = "halloween_ghoul_game_ftue_flag";
      
      private var m_featureName:String = null;
      
      private var m_grids:Object = [];
      
      private var m_gridImages:Array = [];
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_tutorialMC:MovieClip;
      
      private var m_dooberMC:MovieClip;
      
      private var m_referenceMC:MovieClip;
      
      private var m_partRefMc:FarmIcon;
      
      private var m_referenceHighlightMC:MovieClip;
      
      private var m_gridMC:MovieClip;
      
      private var m_gridHighlightMc:MovieClip;
      
      private var m_congratsMc:MovieClip;
      
      private var m_playNextBt:FarmAnimatedTextButton;
      
      private var m_congratsTf1:ZwTextField;
      
      private var m_congratsTf2:ZwTextField;
      
      private var m_plainTf:ZwTextField;
      
      private var m_consumableFrame:HalloweenInnovationGhoulConsumableFrame;
      
      private var m_activeInvention:int;
      
      private var m_gameData:Array;
      
      private var m_piecesPosition:Array;
      
      private var m_piecesItemCode:Array;
      
      private var m_activePart:int;
      
      private var m_rewardFriendlyName:String;
      
      private var m_isPopUPShown:Number = 1;
      
      public function HalloweenInnovationGhoulGameWindow()
      {
         var inventionData:Object = this.manager.getActiveGameData();
         var gameData:Object = inventionData.gameData;
         super(this.FEATURE_NAME,this.manager.getGameDialogUrl(),NUM_TUTORIAL_SCENES);
         this.m_featureName = this.FEATURE_NAME;
         this.m_activeInvention = inventionData.activeInvention;
         this.m_activePart = inventionData.activePart;
         this.m_gameData = gameData.part;
         this.m_piecesPosition = gameData.piecesPosition;
         this.m_piecesItemCode = gameData.itemCodes;
         this.m_rewardFriendlyName = this.manager.getFriendlyNameForReward(this.m_activeInvention,this.m_activePart).toString();
      }
      
      private function get manager() : HalloweenInnovationGhoulManager
      {
         return HalloweenInnovationGhoulManager.getInstance(this.FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var imageIcon:String = null;
         var iconUrl:String = null;
         var prefixIconUrl:String = null;
         var cell:int = 0;
         var grid:String = null;
         var itemName:String = null;
         var i:int = 0;
         var j:int = 0;
         var isGridCellRevealed:Boolean = false;
         var layer:int = 0;
         var icon_mc:MovieClip = null;
         var icon:FarmIcon = null;
         var item:FarmItem = null;
         var iconPath:String = null;
         var iconURL:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Marble’s " + this.manager.getInventionName(this.m_activeInvention).toString()));
         }
         if(m_window.hasOwnProperty(this.SUBTITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],"Find the pieces of this part to give life to the decorative invention! "));
         }
         if(m_window.hasOwnProperty(this.REWARD_MC))
         {
            this.addRewardMc(m_window[this.REWARD_MC] as MovieClip,"Find the part to win this!");
         }
         if(m_window.hasOwnProperty(this.GRID_MC))
         {
            this.m_gridMC = m_window[this.GRID_MC] as MovieClip;
            if(this.m_gridMC.hasOwnProperty(this.HIGHLIGHT_MC))
            {
               this.m_gridHighlightMc = this.m_gridMC[this.HIGHLIGHT_MC] as MovieClip;
            }
            imageIcon = "imageicon{0}_mc";
            for(i = 0; i < this.NUM_GRID_IMAGES; i++)
            {
               prefixIconUrl = "assets/newsfeed/" + this.m_piecesItemCode[i];
               iconUrl = Global.getAssetURL(prefixIconUrl);
               addWidget(this.m_gridImages[i] = new FarmIcon(this.m_gridMC[StringUtil.substitute(imageIcon,i)]));
               (this.m_gridImages[i] as FarmIcon).loadIcon(iconUrl);
               (this.m_gridImages[i] as FarmIcon).x += this.manager.decryptData(this.m_piecesPosition[i]["y"]) * CELL_WIDTH;
               (this.m_gridImages[i] as FarmIcon).y += this.manager.decryptData(this.m_piecesPosition[i]["x"]) * CELL_HEIGHT;
               (this.m_gridImages[i] as FarmIcon).visible = true;
            }
            cell = 0;
            grid = "slot_{0}_mc";
            itemName = null;
            for(i = 0; i < this.NUM_GRIDS_ROW; i++)
            {
               for(j = 0; j < this.NUM_GRIDS_COL; j++)
               {
                  isGridCellRevealed = Boolean(this.m_gameData[i][j][1]);
                  layer = this.manager.decryptData(this.m_gameData[i][j][0]);
                  addWidget(this.m_grids[cell] = new FarmAnimatedButton(this.m_gridMC[StringUtil.substitute(grid,cell)],null));
                  var _temp_3:* = this.m_grids[cell];
                  MouseEvent.CLICK;
                  _temp_3.callback = this.onGridClick(cell,i,j);
                  if(layer == 3)
                  {
                     itemName = this.manager.decryptItem(this.m_gameData[i][j][0]);
                  }
                  (this.m_grids[cell].element.cell_mc as MovieClip).visible = true;
                  (this.m_grids[cell].element.break_mc as MovieClip).visible = false;
                  if(isGridCellRevealed)
                  {
                     (this.m_grids[cell].element.cell_mc as MovieClip).visible = false;
                     if(layer != 3 && layer != 2)
                     {
                        (this.m_grids[cell] as FarmAnimatedButton).enabled = false;
                     }
                     if(!(layer == 1 || layer == 0))
                     {
                        if(layer == 3 || layer == 2)
                        {
                           if(layer == 3)
                           {
                              item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                           }
                           else
                           {
                              iconPath = Global.getAssetURL("assets/dialogs/halloweenmad/innovation/firebolt2.png");
                           }
                           icon_mc = this.m_grids[cell].element.icon_mc as MovieClip;
                           icon = new FarmIcon(icon_mc);
                           if(layer == 3)
                           {
                              this.addTooltip(icon,item.friendlyTitle + ". Find it in your gift box.");
                              icon.loadIcon(item.icon);
                           }
                           else
                           {
                              this.addTooltip(icon,"Firebolt");
                              icon.loadIcon(iconPath);
                           }
                           icon.setIconSize(35,35);
                        }
                     }
                  }
                  cell++;
               }
            }
            this.m_gridMC.visible = true;
            this.m_gridHighlightMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.WHAT_IS_THIS_MC))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window[this.WHAT_IS_THIS_MC],"",this.onHowDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TUTORIAL_MC))
         {
            this.m_tutorialMC = m_window[this.TUTORIAL_MC] as MovieClip;
            this.m_tutorialMC.visible = false;
         }
         if(m_window.hasOwnProperty(this.DOOBER_MC))
         {
            this.m_dooberMC = m_window[this.DOOBER_MC] as MovieClip;
            this.m_dooberMC.visible = false;
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumableFrame = new HalloweenInnovationGhoulConsumableFrame(m_window[this.CONSUMABLE_MC],this.m_featureName,this.manager,"gameWindow");
            this.m_consumableFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.REFERENCE_MC))
         {
            this.m_referenceMC = m_window[this.REFERENCE_MC] as MovieClip;
            if(this.m_referenceMC.hasOwnProperty(this.PART_REF_MC))
            {
               this.m_partRefMc = addWidget(new FarmIcon(this.m_referenceMC[this.PART_REF_MC])) as FarmIcon;
               this.m_partRefMc.loadIcon(this.manager.getAssetURL(this.manager.PART_ICON_WITH_BORDER_LARGE,this.m_activeInvention,this.m_activePart));
            }
            if(this.m_referenceMC.hasOwnProperty(this.HIGHLIGHT_MC))
            {
               this.m_referenceHighlightMC = this.m_referenceMC[this.HIGHLIGHT_MC] as MovieClip;
            }
            if(this.m_referenceMC.hasOwnProperty(this.DESCRIPTION_TF))
            {
               addWidget(new ZwTextField(this.m_referenceMC[this.DESCRIPTION_TF],"Part present behind glass cells"));
            }
            this.m_referenceMC.visible = true;
            this.m_referenceHighlightMC.visible = false;
         }
         if(m_window.hasOwnProperty(this.IMAGE_PREVIEW_MC))
         {
         }
         if(m_window.hasOwnProperty(this.CONGRATS_MC))
         {
            this.m_congratsMc = m_window[this.CONGRATS_MC] as MovieClip;
            if(this.m_congratsMc.hasOwnProperty(this.REWARD_MC))
            {
               this.addRewardMc(this.m_congratsMc[this.REWARD_MC] as MovieClip,"You have won this!");
            }
            if(this.m_congratsMc.hasOwnProperty(this.CONGRATS1_TF))
            {
               addWidget(this.m_congratsTf1 = new ZwTextField(this.m_congratsMc[this.CONGRATS1_TF],"Congratulation!"));
            }
            if(this.m_congratsMc.hasOwnProperty(this.CONGRATS2_TF))
            {
               addWidget(this.m_congratsTf2 = new ZwTextField(this.m_congratsMc[this.CONGRATS2_TF],"You have found the part and also won " + this.m_rewardFriendlyName + " for your effort!"));
            }
            if(this.m_congratsMc.hasOwnProperty(this.PLAYNEXT_TF))
            {
               addWidget(this.m_plainTf = new ZwTextField(this.m_congratsMc[this.PLAYNEXT_TF],"Click here to continue searching for more parts"));
            }
            if(this.m_congratsMc.hasOwnProperty(this.PLAYNEXT_BT))
            {
               addWidget(this.m_playNextBt = new FarmAnimatedTextButton(this.m_congratsMc[this.PLAYNEXT_BT],"Play for next part",this.onNextBtnClick));
            }
            if(this.m_congratsMc.hasOwnProperty(this.COMPLETEPART_MC))
            {
               new FarmIcon(this.m_congratsMc[this.COMPLETEPART_MC],this.manager.getAssetURL(this.manager.PART_ICON_BORDERLESS_LARGE,this.m_activeInvention,this.m_activePart));
            }
            if(this.m_congratsMc.hasOwnProperty(this.ICON_MC))
            {
               iconURL = this.m_activePart == this.manager.FINAL_PART ? this.manager.getAssetURL(this.manager.ANIMAL_FINAL_ICON_LARGE,this.m_activeInvention,this.m_activePart + 1) : this.manager.getAssetURL(this.manager.ANIMAL_ICON_LARGE,this.m_activeInvention,this.m_activePart + 1);
               new FarmIcon(this.m_congratsMc[this.ICON_MC],iconURL);
            }
            this.m_playNextBt.visible = true;
            this.m_playNextBt.enabled = true;
            this.m_plainTf.visible = true;
            this.m_congratsTf1.visible = true;
            this.m_congratsTf2.visible = true;
         }
         if(!Global.player.getSeenFlag(this.HALLOWEEN_GHOUL_GAME_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEEN_GHOUL_GAME_FTUE_FLAG);
            this.showTutorial();
         }
      }
      
      private function addRewardMc(element:MovieClip, title:String) : void
      {
         var owlAnimMC:MovieClip = null;
         var owlStaticMC:MovieClip = null;
         var rewardIcon:FarmIcon = null;
         if(element.hasOwnProperty(this.REWARD_MC))
         {
            rewardIcon = new FarmIcon(element[this.REWARD_MC]);
            rewardIcon.loadIcon(this.manager.getRewardIcon(this.m_activeInvention,this.m_activePart));
            this.addTooltip(rewardIcon,this.m_rewardFriendlyName);
         }
         if(element.hasOwnProperty(this.REWARD_NAME_TF))
         {
            new ZwTextField(element[this.REWARD_NAME_TF],this.m_rewardFriendlyName);
         }
         if(element.hasOwnProperty(this.SUBTEXT_TF))
         {
            new ZwTextField(element[this.SUBTEXT_TF],title);
         }
         if(element.hasOwnProperty(OWL_ANIM_MC))
         {
            owlAnimMC = element[OWL_ANIM_MC] as MovieClip;
            owlAnimMC.visible = false;
         }
         if(element.hasOwnProperty(OWL_STATIC_MC))
         {
            owlStaticMC = element[OWL_STATIC_MC] as MovieClip;
            owlStaticMC.visible = true;
         }
         element.visible = true;
         element.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardMcMouseRollOver(owlStaticMC,owlAnimMC));
         element.addEventListener(MouseEvent.MOUSE_OUT,this.onRewardMcMouseRollOut(owlStaticMC,owlAnimMC));
      }
      
      private function addTooltip(element:FarmIcon, msg:String) : void
      {
         if(element.tooltip)
         {
            element.tooltip.release();
         }
         element.attachTooltip(new FarmTextTooltip(msg));
      }
      
      private function onRewardMcMouseRollOut(owlStaticMC:MovieClip, owlAnimMC:MovieClip) : Function
      {
         return function(event:MouseEvent):void
         {
            owlStaticMC.visible = true;
            owlAnimMC.visible = false;
         };
      }
      
      private function onRewardMcMouseRollOver(owlStaticMC:MovieClip, owlAnimMC:MovieClip) : Function
      {
         return function(event:MouseEvent):void
         {
            owlStaticMC.visible = false;
            owlAnimMC.visible = true;
         };
      }
      
      private function onNextBtnClick(event:MouseEvent) : void
      {
         this.close();
         if(this.m_activeInvention == this.manager.FINAL_INVENTION && this.m_activePart == this.manager.FINAL_PART)
         {
            return;
         }
         this.manager.showGameUI();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function onPartCompletion(invention:int, part:int) : void
      {
         this.manager.addRewardToGiftBox(invention,part);
         this.disableGrid();
         this.m_referenceHighlightMC.visible = true;
         this.m_referenceHighlightMC.play();
         this.m_gridHighlightMc.visible = true;
         this.m_gridHighlightMc.play();
         this.m_gridMC.enabled = false;
         setTimeout(function():void
         {
            m_referenceHighlightMC.visible = false;
            m_gridHighlightMc.visible = false;
            m_congratsMc.visible = true;
         },4000);
      }
      
      public function disableGrid() : void
      {
         var j:int = 0;
         var cell:int = 0;
         for(var i:int = 0; i < this.NUM_GRIDS_ROW; i++)
         {
            for(j = 0; j < this.NUM_GRIDS_COL; j++)
            {
               (this.m_grids[cell] as FarmAnimatedButton).enabled = false;
               cell++;
            }
         }
      }
      
      private function onInventionCompletion(invention:int, part:int) : void
      {
         this.manager.addRewardToGiftBox(invention,part);
         this.disableGrid();
         this.m_referenceHighlightMC.visible = true;
         this.m_referenceHighlightMC.play();
         this.m_gridHighlightMc.visible = true;
         this.m_gridHighlightMc.play();
         setTimeout(function():void
         {
            m_referenceHighlightMC.visible = false;
            m_gridHighlightMc.visible = false;
            manager.showInventionRewardPopup(m_activeInvention,m_activePart);
            close();
         },4000);
      }
      
      private function grantFirebolt(cellIndex:int) : void
      {
         this.m_dooberMC.visible = true;
         this.m_dooberMC.play();
         var iconPath:String = Global.getAssetURL("assets/newsfeed/firebolt_icon.png");
         var icon_mc:MovieClip = this.m_grids[cellIndex].element.icon_mc as MovieClip;
         var icon:FarmIcon = new FarmIcon(icon_mc);
         this.addTooltip(icon,"Firebolt");
         icon.loadIcon(iconPath);
         icon.setIconSize(35,35);
         this.manager.addOrderboardProgress(this.NUM_FIREBOLT_GAINED);
      }
      
      private function grantConusmable(gameData:Array, row:int, col:int, cellIndex:int) : void
      {
         var consumableName:String = this.manager.decryptItem(gameData[row][col][0]);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(consumableName);
         var icon_mc:MovieClip = this.m_grids[cellIndex].element.icon_mc as MovieClip;
         var icon:FarmIcon = new FarmIcon(icon_mc);
         this.addTooltip(icon,item.friendlyTitle + ". Find it in your gift box.");
         icon.loadIcon(item.icon);
         icon.setIconSize(35,35);
         Global.player.addGift(consumableName);
      }
      
      private function checkGameProgress(response:Object) : void
      {
         if(!response[this.manager.KEY_GAME_DATA][KEY_HAS_FINISHED_GAME])
         {
         }
         if(response[this.manager.KEY_GAME_DATA][KEY_HAS_FINISHED_INVENTION])
         {
            this.onInventionCompletion(this.m_activeInvention,this.m_activePart);
         }
         else if(response[this.manager.KEY_GAME_DATA][KEY_HAS_FINISHED_PART])
         {
            this.onPartCompletion(this.m_activeInvention,this.m_activePart);
         }
      }
      
      private function onUpdateGrid(result:Object) : void
      {
         var cellData:Array = null;
         var cellIndex:int = 0;
         var row:int = 0;
         var col:int = 0;
         var inventionData:Object = null;
         var gameData:Object = null;
         var isGridCellRevealed:Boolean = false;
         var layer:int = 0;
         if(Boolean(result) && !result.hasOwnProperty(KEY_ERROR))
         {
            if(Boolean(result && result.hasOwnProperty(KEY_ERROR_ISF)) && Boolean(result[KEY_ERROR_ISF] == this.INSUFFICIENT_FIREBOLT) && Boolean(this.m_isPopUPShown))
            {
               this.m_isPopUPShown = 0;
               tintWindow();
               enableInput = false;
               this.onInSufficientFireboltPopUp();
            }
            else if(this.m_isPopUPShown)
            {
               if(!(Boolean(result) && result[this.manager.KEY_GAME_DATA] == NA))
               {
                  this.manager.saveFeatureOptionsKey(this.manager.GAME_INVENTIONS_KEY,result[this.manager.KEY_GAME_DATA][this.manager.GAME_INVENTIONS_KEY]);
                  cellData = result["cellData"];
                  cellIndex = int(cellData[0]);
                  row = int(cellData[1]);
                  col = int(cellData[2]);
                  inventionData = this.manager.getActiveGameData();
                  gameData = inventionData.gameData;
                  this.m_gameData = gameData.part;
                  isGridCellRevealed = Boolean(this.m_gameData[row][col][1]);
                  layer = this.manager.decryptData(this.m_gameData[row][col][0]);
                  if(isGridCellRevealed && Boolean(this.m_grids[cellIndex].element))
                  {
                     if(layer == 3 || layer == 2)
                     {
                        (this.m_grids[cellIndex] as FarmAnimatedButton).enabled = true;
                     }
                     if(!(layer == 1 || layer == 0))
                     {
                        if(layer == 2)
                        {
                           this.grantFirebolt(cellIndex);
                        }
                        else if(layer == 3)
                        {
                           this.grantConusmable(this.m_gameData,row,col,cellIndex);
                        }
                     }
                  }
                  this.checkGameProgress(result);
               }
            }
         }
      }
      
      private function onGridClick(cellIndex:int, row:int, col:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var layer:* = undefined;
            var numberFirebolts:* = manager.getOrderboardProgress();
            if(numberFirebolts >= NUM_FIREBOLT_REQUIRED && !m_gameData[row][col][1])
            {
               (m_grids[cellIndex] as FarmAnimatedButton).enabled = false;
               layer = manager.decryptData(m_gameData[row][col][0]);
               (m_grids[cellIndex].element.break_mc as MovieClip).visible = true;
               (m_grids[cellIndex].element.break_mc as MovieClip).play();
               if(layer == 3 || layer == 2)
               {
                  (m_grids[cellIndex] as FarmAnimatedButton).enabled = true;
               }
               (m_grids[cellIndex].element.cell_mc as MovieClip).visible = false;
               manager.reduceOrderboardProgress(NUM_FIREBOLT_REQUIRED);
               refreshWindow();
               manager.updateGrid(cellIndex,row,col,m_activeInvention,m_activePart,onUpdateGrid);
            }
            else if(numberFirebolts < NUM_FIREBOLT_REQUIRED && !m_gameData[row][col][1] && Boolean(m_isPopUPShown))
            {
               m_isPopUPShown = 0;
               tintWindow();
               enableInput = false;
               onInSufficientFireboltPopUp();
            }
         };
      }
      
      override public function close() : void
      {
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
            this.manager.m_window.enableInput = true;
            this.manager.m_window.refreshWindow();
            this.manager.m_window.visible = true;
         }
         super.close();
      }
      
      override public function refreshWindow() : void
      {
         if(this.m_consumableFrame)
         {
            this.m_consumableFrame.refresh();
         }
      }
      
      public function onInSufficientFireboltPopUp() : void
      {
         var sellMessage:String = "Not enough firebolts to play the game. Please complete some tasks from orderboard.";
         UI.displayMessage(sellMessage,GenericPopup.TYPE_OK,this.gameWindowUntint,"",true);
      }
      
      public function gameWindowUntint(event:GenericPopupEvent) : void
      {
         untintWindow();
         enableInput = true;
         this.close();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
   }
}

