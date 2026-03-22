// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-FileCopyrightText: 2025 Martin Sh <hemisputnik@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import org.kde.kitemmodels

KSortFilterProxyModel {
    id: filteredModel
    property alias sourceModel: filteredModel.sourceModel

    property string primaryFilter: ""
    property string secondaryFilter: "default"

    onPrimaryFilterChanged: {
        filteredModel.filterRegularExpression = RegExp(primaryFilter.replace("+", "\\+").replace("(", "\\(").replace(")", "\\)"), "gi");
    }

    onSecondaryFilterChanged: filteredModel.invalidateFilter()

    function itemMatchesPrimaryFilter(item) {
        if (primaryFilter.length == 0)
            return true;

        const itemText = sourceModel.data(item, TodoModel.DescriptionRole);

        return itemText.match(filterRegularExpression) || itemText.length == 0
    }

    function itemMatchesSecondaryFilter(item) {
        switch (secondaryFilter) {
        case "default":
            return true;
        case "hasDueDate":
            return sourceModel.data(item, TodoModel.DueDateRole) != "";
        case "isNotCompleted":
            return !sourceModel.data(item, TodoModel.CompletionRole);
        case "isCompleted":
            return sourceModel.data(item, TodoModel.CompletionRole);
        default:
            return false;
        }
    }

    filterRoleName: "description"
    sortRoleName: "description"
    filterRowCallback: function (source_row, source_parent) {
        const item = sourceModel.index(source_row, 0, source_parent);
        return itemMatchesPrimaryFilter(item) && itemMatchesSecondaryFilter(item);
    }
}
