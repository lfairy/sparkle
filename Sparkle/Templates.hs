{-# LANGUAGE OverloadedStrings, RecordWildCards #-}
{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

module Sparkle.Templates where

import Text.Blaze ((!))
import Text.Blaze.Html5 (Html, toHtml)
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import Sparkle.Common
import Sparkle.Types


pageTemplate :: Project -> Html
pageTemplate = outerTemplate <$> view projTitle <*> planTemplate . view projTasks


outerTemplate :: Text -> Html -> Html
outerTemplate title body = H.docTypeHtml $ do
    H.head $ do
        H.meta ! A.charset "utf-8"
        H.title $ toHtml title
        H.link ! A.rel "stylesheet" ! A.href "/static/core.css"
    H.body $ do
        H.h1 $ toHtml title
        H.div ! A.id "content" $ body
        H.footer $ do
            H.p $ do
                "Powered by "
                H.a ! A.href "http://lfairy.github.io/sparkle" $ "Sparkle"


planTemplate :: Tasks -> Html
planTemplate = (H.section ! A.id "plan") . dumpChildren . getTasks
  where
    dumpChildren tasks = H.ul $
        forM_ tasks $ \(Node t cs) ->
            H.li ! onlyIf (notNull cs)
                          (A.class_ "task-has-children") $ do
                -- Task title
                H.label $ do
                    H.input ! A.type_ "checkbox"
                            ! A.disabled "disabled"
                            ! onlyIf (t^.taskDone) (A.checked "checked")
                    "\xA0" -- no-break space
                    H.span $ toHtml (t^.taskTitle)

                -- Recurse in child tasks
                when (notNull cs) $
                    dumpChildren cs


-- | @onlyif b x@ returns @x@ /only if/ @b@ is True.
onlyIf :: Monoid a => Bool -> a -> a
onlyIf False _ = mempty
onlyIf True  x = x

-- | Determine if the given list is not empty. Synonym for @not . null@.
notNull :: [a] -> Bool
notNull = not . null
