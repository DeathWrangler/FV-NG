package Widgets.View.Icons
{
   import Widgets.Parser.XMLDialogParser;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IconSwfAssetBase extends IconImageBase
   {
      
      public var m_linkageName:String = null;
      
      public var m_hasDeadFrame:Boolean = false;
      
      public var m_showDeadFrame:Boolean = false;
      
      public var m_playbackRate:Number = 1;
      
      private var m_framesPassed:Number = 0;
      
      public function IconSwfAssetBase(aKeyValuePairs:Array, aTokenValues:Array)
      {
         super(aKeyValuePairs,aTokenValues);
         var bHasDeadFrame:Boolean = getAttributeValue(XMLDialogParser.BOOL_STYLE_KEY_HAS_DEADFRAME);
         var sLinkage:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_LINKAGE);
         var nPlayrate:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_PLAYRATE);
         var bShowDeadFrame:Boolean = getAttributeValue(XMLDialogParser.BOOL_STYLE_KEY_SHOW_DEADFRAME);
         if(Boolean(m_loader) && m_loader.parent != null)
         {
            removeChild(m_loader);
         }
         this.m_linkageName = sLinkage;
         this.m_linkageName = replaceTokens(this.m_linkageName,aTokenValues);
         this.m_playbackRate = nPlayrate;
         this.m_hasDeadFrame = bHasDeadFrame;
         this.m_showDeadFrame = bShowDeadFrame;
      }
      
      override protected function onLoaderComplete(event:Event) : void
      {
         var TheClass:Class = null;
         var TheInstance:MovieClip = null;
         var info:LoaderInfo = event.currentTarget as LoaderInfo;
         dtrace("swf load complete: " + m_url);
         if(m_loader.contentLoaderInfo.applicationDomain.hasDefinition(this.m_linkageName))
         {
            dtrace("swf about to instance linkageName: " + this.m_linkageName);
            TheClass = m_loader.contentLoaderInfo.applicationDomain.getDefinition(this.m_linkageName) as Class;
            TheInstance = new TheClass() as MovieClip;
            TheInstance.addEventListener(Event.ENTER_FRAME,this.everyFrame);
            TheInstance.stop();
            addChild(TheInstance);
            killSpinTimer();
            killSpinner();
         }
         else
         {
            dtrace("swf DOESN\'T HAVE linkageName: " + this.m_linkageName);
            killSpinTimer();
            drawSpinnerFail();
            addToolTip("ERROR: swf DOESN\'T HAVE linkageName: " + this.m_linkageName);
         }
      }
      
      public function everyFrame(event:Event) : void
      {
         ++this.m_framesPassed;
         if(this.m_framesPassed * this.m_playbackRate < 1)
         {
            return;
         }
         this.m_framesPassed = 0;
         var asset:MovieClip = event.target as MovieClip;
         if(this.m_showDeadFrame && this.m_hasDeadFrame)
         {
            asset.gotoAndStop(asset.totalFrames);
         }
         else if(!this.m_showDeadFrame && this.m_hasDeadFrame)
         {
            if(asset.currentFrame >= asset.totalFrames - 1)
            {
               asset.gotoAndStop(1);
            }
            else
            {
               asset.nextFrame();
            }
         }
         else if(asset.currentFrame >= asset.totalFrames)
         {
            asset.gotoAndStop(1);
         }
         else
         {
            asset.nextFrame();
         }
      }
   }
}

