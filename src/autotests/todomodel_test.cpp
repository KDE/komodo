// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>
#include <QTest>
#include <QTextDocumentFragment>

#include "../models/TodoModel.h"
using namespace Qt::StringLiterals;

class TodoModelTest : public QObject
{
    Q_OBJECT

private:
    TodoModel *todoModel;
    QTemporaryDir *tempDir;
    QUrl testFilePath;

    // All these tests must be run in order!
private Q_SLOTS:
    void initTestCase();
    void testParseTodo_data();
    void testParseTodo();
    void testLoadFile();
    void testMakeNewTodo();
    void testEditTodo();
    void testDeleteTodo();
    void testSaveFile();
    void cleanupTestCase();
};

void TodoModelTest::initTestCase()
{
    todoModel = new TodoModel(this);
    tempDir = new QTemporaryDir();
    QFile origFile(QFINDTESTDATA("todo.txt"));

    origFile.copy(tempDir->filePath(u"todo.txt"_s));
    testFilePath = QUrl::fromLocalFile(tempDir->filePath(u"todo.txt"_s));
    QVERIFY(QFileInfo(testFilePath.toLocalFile()).exists());
}
void TodoModelTest::testParseTodo_data()
{
    QTest::addColumn<QString>("description");
    QTest::addColumn<bool>("completed");
    QTest::addColumn<QString>("priority");
    QTest::addColumn<QString>("completionDate");
    QTest::addColumn<QString>("creationDate");
    QTest::addColumn<QStringList>("contexts");
    QTest::addColumn<QStringList>("projects");
    QTest::addColumn<QStringList>("keyValuePairs");
    QTest::addColumn<QString>("prettyDescription");
    QTest::addColumn<QString>("dueDate");

    QTest::addRow("Simple uncompleted task") << u"(B) 2025-06-21 Outline chapter 5 chapter:5 +Novel @Computer"_s << false << u"(B)"_s << u""_s
                                             << u"2025-06-21"_s << QStringList{u"@Computer"_s} << QStringList{u"+Novel"_s} << QStringList{u"chapter:5"_s}
                                             << u"Outline chapter 5 +Novel @Computer"_s << u""_s;

    QTest::addRow("Completed task") << u"x 2025-06-25 2025-06-21 Download Todo.txt mobile app note:blaa_text @Phone pri:F"_s << true << u""_s << u"2025-06-25"_s
                                    << u"2025-06-21"_s << QStringList{u"@Phone"_s} << QStringList{} << QStringList{u"note:blaa_text"_s, u"pri:F"_s}
                                    << u"Download Todo.txt mobile app @Phone"_s << u""_s;

    QTest::addRow("Task with only description") << u"This task has only description"_s << false << u""_s << u""_s << u""_s << QStringList{} << QStringList{}
                                                << QStringList{} << u"This task has only description"_s << u""_s;

    QTest::addRow("Completed task with only description") << u"x This task has only description"_s << true << u""_s << u""_s << u""_s << QStringList{}
                                                          << QStringList{} << QStringList{} << u"This task has only description"_s << u""_s;

    QTest::addRow("Task with multiple contexts, projects and keyvaluepairs")
        << u"(E) 2025-06-21 This is a @Complicated +Task with +Stuff task:123 +Test @QTest @Computer due:2025-12-02 thing:stuff"_s << false << u"(E)"_s << u""_s
        << u"2025-06-21"_s << QStringList{u"@Complicated"_s, u"@QTest"_s, u"@Computer"_s} << QStringList{u"+Task"_s, u"+Stuff"_s, u"+Test"_s}
        << QStringList{u"task:123"_s, u"due:2025-12-02"_s, u"thing:stuff"_s} << u"This is a @Complicated +Task with +Stuff +Test @QTest @Computer"_s
        << u"2025-12-02"_s;

    QTest::addRow("Uncompleted task with completion and creation date")
        << u"(F) 2025-06-25 2025-06-21 Broken task!"_s << false << u"(F)"_s << u""_s << u"2025-06-25"_s << QStringList{} << QStringList{} << QStringList{}
        << u"2025-06-21 Broken task!"_s << u""_s;

    QTest::addRow("Task with URL in keyval pair") << u"(C) 2025-06-21 Add cover sheets link:https://example.com/lo%20l/ @Office +TPSReports"_s << false
                                                  << u"(C)"_s << u""_s << u"2025-06-21"_s << QStringList{u"@Office"_s} << QStringList{u"+TPSReports"_s}
                                                  << QStringList{u"link:https://example.com/lo%20l/"_s} << u"Add cover sheets @Office +TPSReports"_s << u""_s;

    QTest::addRow("Task with URL inside description") << u"(C) 2025-06-21 Add cover sheets https://example.com/lo%20l/ @Office +TPSReports"_s << false
                                                      << u"(C)"_s << u""_s << u"2025-06-21"_s << QStringList{u"@Office"_s} << QStringList{u"+TPSReports"_s}
                                                      << QStringList{u"https://example.com/lo%20l/"_s} << u"Add cover sheets @Office +TPSReports"_s << u""_s;
}
void TodoModelTest::testParseTodo()
{
    QFETCH(QString, description);
    QFETCH(bool, completed);
    QFETCH(QString, priority);
    QFETCH(QString, completionDate);
    QFETCH(QString, creationDate);
    QFETCH(QStringList, contexts);
    QFETCH(QStringList, projects);
    QFETCH(QStringList, keyValuePairs);
    QFETCH(QString, prettyDescription);
    QFETCH(QString, dueDate);

    auto todo = todoModel->parseTodoFromDescription(description);

    QCOMPARE(todo.description(), description);
    QCOMPARE(todo.completed(), completed);
    QCOMPARE(todo.priority(), priority);
    QCOMPARE(todo.completionDate(), completionDate);
    QCOMPARE(todo.creationDate(), creationDate);
    QCOMPARE(todo.contexts(), contexts);
    QCOMPARE(todo.projects(), projects);
    QCOMPARE(todo.keyValuePairs(), keyValuePairs);
    // PrettyDescription has HTML items in it, so just clean those out
    QCOMPARE(QTextDocumentFragment::fromHtml(todo.prettyDescription()).toPlainText(), prettyDescription);
    QCOMPARE(todo.dueDate(), dueDate);
}
void TodoModelTest::testLoadFile()
{
    todoModel->setFilePath(testFilePath);
    QVERIFY(todoModel->loadFile());
    QVERIFY(todoModel->todos().length() == 13);
}
void TodoModelTest::testMakeNewTodo()
{
    QString newTodo = u"(D) 2025-07-18 This is a new todo created from the +test @QTesting stuff:things"_s;
    todoModel->addTodo(newTodo);

    bool found = false;
    for (const auto &todo : todoModel->todos()) {
        if (todo.description() == newTodo) {
            found = true;
            QCOMPARE(todo.completed(), false);
            QCOMPARE(todo.priority(), u"(D)"_s);
            QCOMPARE(todo.completionDate(), u""_s);
            QCOMPARE(todo.creationDate(), u"2025-07-18"_s);
            QCOMPARE(todo.contexts(), QStringList{u"@QTesting"_s});
            QCOMPARE(todo.projects(), QStringList{u"+test"_s});
            QCOMPARE(todo.keyValuePairs(), QStringList{u"stuff:things"_s});
            // PrettyDescription has HTML items in it, so just clean those out
            QCOMPARE(QTextDocumentFragment::fromHtml(todo.prettyDescription()).toPlainText(), u"This is a new todo created from the +test @QTesting"_s);
            QCOMPARE(todo.dueDate(), u""_s);
            break;
        }
    }
    QVERIFY(found);
}
void TodoModelTest::testEditTodo()
{
    QString newTodo = u"(C) 2025-07-10 This is another new todo created during +TESTING @QTestingAgain yee:haw"_s;
    QString editedTodo = u"x (A) 2025-07-15 2025-07-13 This is now an edited todo which was created during +TESTING @QTestingAgain"_s;
    todoModel->addTodo(newTodo);
    auto index = todoModel->indexFromDescription(newTodo);

    todoModel->setData(index, editedTodo, TodoModel::DescriptionRole);

    bool found = false;
    for (const auto &todo : todoModel->todos()) {
        if (todo.description() == editedTodo) {
            found = true;
            QCOMPARE(todo.completed(), true);
            QCOMPARE(todo.priority(), u"(A)"_s);
            QCOMPARE(todo.completionDate(), u"2025-07-15"_s);
            QCOMPARE(todo.creationDate(), u"2025-07-13"_s);
            QCOMPARE(todo.contexts(), QStringList{u"@QTestingAgain"_s});
            QCOMPARE(todo.projects(), QStringList{u"+TESTING"_s});
            QCOMPARE(todo.keyValuePairs(), QStringList{});
            // PrettyDescription has HTML items in it, so just clean those out
            QCOMPARE(QTextDocumentFragment::fromHtml(todo.prettyDescription()).toPlainText(),
                     u"This is now an edited todo which was created during +TESTING @QTestingAgain"_s);
            QCOMPARE(todo.dueDate(), u""_s);
            break;
        }
    }
    QVERIFY(found);
}
void TodoModelTest::testDeleteTodo()
{
    QString newTodo = u"This todo should be deleted!"_s;
    todoModel->addTodo(newTodo);
    auto index = todoModel->indexFromDescription(newTodo);
    todoModel->deleteTodo(index);
    auto found = todoModel->indexFromDescription(newTodo);
    QVERIFY(!found.isValid());
}
void TodoModelTest::testSaveFile()
{
    QStringList beforeSave;
    QStringList afterSave;
    QFile file(testFilePath.toLocalFile());
    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QTextStream firstStream(&file);
    while (!firstStream.atEnd()) {
        QString line = firstStream.readLine();
        beforeSave.append(line);
    }
    file.close();

    QString newTodo = u"Adding new todo item should save the file"_s;
    todoModel->addTodo(newTodo);
    // But let's save it anyway for testing purposes
    QVERIFY(todoModel->saveFile());

    QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
    QTextStream secondStream(&file);
    while (!secondStream.atEnd()) {
        QString line = secondStream.readLine();
        afterSave.append(line);
    }
    file.close();

    qDebug() << "Text before saving" << beforeSave;
    qDebug() << "Text after saving" << afterSave;
    QVERIFY(afterSave.count() > beforeSave.count());
}
void TodoModelTest::cleanupTestCase()
{
    delete todoModel;
    delete tempDir;
}

QTEST_MAIN(TodoModelTest)

#include "todomodel_test.moc"