package Widgets.Windows
{
   import Managers.FishingV2Manager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Fishing2XBoostWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private const TILE_NAME:String = "xcl_rubbletreasure_payer12";
      
      private var m_mainWindow:FishingCollectionWindow;
      
      private var m_tackleWindow:FishingTackleBoxWindow;
      
      public var m_closeBt:SimpleButton;
      
      public function Fishing2XBoostWindow(featureName:String, assetPath:String, mainWindow:FishingCollectionWindow, tackleWindow:FishingTackleBoxWindow)
      {
         this.m_featureName = featureName;
         this.m_mainWindow = mainWindow;
         this.m_tackleWindow = tackleWindow;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var tileUnlock:Boolean = FishingV2Manager.getInstance().isP12TileUnlocked();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Fishing Frenzy!"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            if(tileUnlock)
            {
               addWidget(new ZwTextField(m_window["body_tf"],"You have fishing access to the Smoothie Pond!"));
            }
            else
            {
               addWidget(new ZwTextField(m_window["body_tf"],"There are a lot of Rare fishes in Smoothie Pond!"));
            }
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_closeBt = m_window.close_bt;
            this.m_closeBt.visible = false;
            this.m_closeBt.addEventListener(MouseEvent.CLICK,this.onAccept);
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            if(tileUnlock)
            {
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Great",this.onAccept));
            }
            else
            {
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Let\'s Go",this.onHighlihtTile));
            }
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            if(tileUnlock)
            {
               addWidget(new ZwTextField(m_window["body2_tf"],"You now have double the chance of catching a Rare fish! Make sure you use the correct Rod!"));
            }
            else
            {
               addWidget(new ZwTextField(m_window["body2_tf"],"Unlock Smoothie Pond to double your chances of getting a Rare fish!"));
            }
         }
      }
      
      public function onAccept(event:Event) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         if(this.m_tackleWindow)
         {
            this.m_tackleWindow.untintWindow();
            this.m_tackleWindow.enableInput = true;
         }
         super.close();
      }
      
      public function onHighlihtTile(event:Event) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
            this.m_mainWindow.m_isClose = 1;
            this.m_mainWindow.close();
         }
         if(this.m_tackleWindow)
         {
            this.m_tackleWindow.untintWindow();
            this.m_tackleWindow.enableInput = true;
            this.m_tackleWindow.close();
         }
         ItemFinderManager.getInstance().highlightWorldItems(this.TILE_NAME);
         super.close();
      }
   }
}

